module FeedHelper

  class Cget
    require 'curb'
    require 'logger'

    @@logger = Logger.new("log/feed_helper.log")
    @@logger.progname = 'FeedHelper'

    DEBUG_MSG_ABORT = "- Aborting can't connect to: "
    DEBUG_MSG_PARAM = " - Parameter: "
    DEBUG_MSG_RECONNECTING = "Reconnecting..."

    def self.get(url)
      count = 1
      curl = Curl::Easy.new
      curl.follow_location = true
      curl.url = url
      curl.timeout = 3

      begin
        curl.perform
        return curl.body

      rescue Curl::Err::HostResolutionError, Curl::Err::ConnectionFailedError
        count += 1
        p DEBUG_MSG_RECONNECTING + url

      retry unless count > 5
        p DEBUG_MSG_ABORT + url
        @@logger.debug DEBUG_MSG_ABORT + url

      rescue Curl::Err::TimeoutError => e
        p e.message
        @@logger.debug DEBUG_MSG_ABORT + url

      rescue Exception => e
        p e.message
        @@logger.error + e.message + DEBUG_MSG_PARAM + url
      end
      nil
    end
  end

  class Facebook
    require 'koala'

    def initialize(oauth_token)
      @graph = Koala::Facebook::API.new(oauth_token)
      @uid = Authentication.find_by(oauth_token: oauth_token).uid
    end

    def get_news_feed
      @graph.get_connections("me","home")
    end

    def process_news_feed
      posts = get_news_feed
      posts.each do |post|
        create_leaflet(post)
      end
    end

    def create_leaflet(post)
      channel = Channel.find_by!(source: @uid)
      content = String.new

      content << ("<p>" + post["story"] + "</p>") unless post["story"].nil?
      content << ("<p>" + post["message"] + "</p>") unless post["message"].nil?
      content << ("<img src=" + CGI.unescapeHTML(post["picture"]) + " />") unless post["picture"].nil?
      content << ("<p><strong>" + post["name"] + "</strong></p>")  unless post["name"].nil?
      content << ("<p>" + post["description"] + "</p>")  unless post["description"].nil?
      content << ("<p><small>" + post["caption"] + "</small></p>")  unless post["caption"].nil?
      content << ("<p>" + post["type"] + "</p>") unless post["type"].nil?

      title = "<a href=http://www.facebook.com/#{post['from']['id']}/>#{post['from']['name']}</a>"
      title << " >> <a href=http://www.facebook.com/#{post['to']['data'][0]['id']}/>#{post['to']['data'][0]['name']}</a>" unless post['to'].nil?

      link = post["link"] || "http://www.facebook.com/#{post['id']}"

      unless Leaflet.where(identifier: post["id"]).exists?
        Leaflet.create!(channel_id: channel.id,
                        identifier: post["id"],
                        title: title,
                        url: link,
                        author: post["from"]["name"],
                        image: post["picture"],
                        content: content,
                        published_at: post["created_time"])
      end
    end

    def get_likes
      liked_pages = []
      url_pages = {}

      user_likes = @graph.get_connections("me","likes")

      user_likes.each do |like|
        liked_pages << like["id"]
      end

      pages = @graph.batch do |batch_api|
        liked_pages.each do |page|
          batch_api.get_object(page)
        end
      end

      pages.each do |page|
        hash = { :url => nil}
        hash[:url] = page["website"].split(%r{[\s,;]}).reject(&:empty?) unless page["website"].nil?
        hash[:fb_link] = page["link"]
        hash[:category] = page["category"]
          #url_pages[page["name"]] = { :url => page["website"].split(%r{[\s,;]}).reject(&:empty?),
                                      #:fb_link => page["link"],
                                      #:category => page["category"] }
          #url_pages << page["website"].split(%r{[\s,]}).reject(&:empty?)
          url_pages[page["name"]] = hash
      end
      url_pages
    end

  end

  class Reddit
    require 'json'

    def initialize(path)
      @path = path
      @url = reddify_url(path)
      json = Cget.get(@url)
      @hash_map = JSON.load(json) unless json.nil?
    end

    def get_title
      @hash_map["data"]["children"].each { |hash| return "/r/" << hash["data"]["subreddit"] }
    end

    def parse(url)
      initialize(url)
    end

    def process_reddit
      @hash_map["data"]["children"].each { |hash|
        create_leaflet(hash["data"]) } unless @hash_map.nil?
    end

    private

    def create_leaflet(hash)
      channel = Channel.find_by!(source: @path)
      unless Leaflet.where(identifier: hash["id"]).exists?
        if !hash["selftext_html"].nil?
          content = CGI.unescapeHTML(hash["selftext_html"])
        elsif !hash["media_embed"]["content"].nil?
          content = CGI.unescapeHTML(hash["media_embed"]["content"])
        elsif !hash["thumbnail"].empty?
          content = "<img src=#{hash["thumbnail"]} />"
        else
          content = "No more content available."
        end
        Leaflet.create!(channel_id: channel.id,
                        identifier: hash["id"],
                        title: hash["title"],
                        url: hash["url"],
                        author: hash["author"],
                        image: hash["thumbnail"],
                        content: content,
                        published_at: Time.at(hash["created_utc"]).utc)
      end
    end

    def reddify_url(url)
      raise FeedNotFoundError if url.empty?
      "http://www.reddit.com/r/" << url << ".json"
    end

  end

  class Scrapper
    require 'addressable/uri'
    require 'nokogiri'

    LINK_TYPE = ['application/rss+xml', 'application/atom+xml']
    XML_NAME = ['rss', 'feed']

    MSG_NO_TITLE = "Title not available."

    def initialize(url)
      @url = parse_link(url)
      @html = Cget.get(url)
    end

    def get_title
      title = Nokogiri::HTML(@html).title
      return MSG_NO_TITLE if title.nil? || title.empty?
      title
    end

    def get_feed
      #if its a xml file, check if its a feed
      return [@url] if Nokogiri::XML(@html).root.respond_to?(:name) && XML_NAME.include?(Nokogiri::XML(@html).root.name)

      feed_urls = []
      Nokogiri::HTML(@html).css('link').each do |link|
        #check all <link> in Head of html for rss/atom
        if link.attribute("type").respond_to?(:value) && LINK_TYPE.include?(link.attribute("type").value)
          #if link got scheme(http) host(example.com)
          if link.attribute("href").value =~ /^#{URI::regexp}$/
            feed_urls << link.attribute("href").value
          else #its relative path so we add the url
            uri = Addressable::URI.parse(@url)
            uri.path = link.attribute("href").value
            feed_urls << uri.to_s
          end
        end
      end
      feed_urls.uniq
    end

    def parse(url)
      initialize(url)
    end

    private

    def parse_link(url)
      uri = Addressable::URI.parse(url)
      if (!uri.scheme)
        url = "http://" + url
      end
      return url if url =~ /^#{URI::regexp}$/
      raise URI::InvalidURIError
    end
  end


  class FeedNotFoundError < StandardError
  end


  class WebFeed
    require 'feedjira'
    require 'digest/md5'

    def initialize(url)
      @url = url
      if (@feed = Feedjira::Feed.fetch_and_parse(url)) == 0
        raise FeedNotFoundError
      end
    end

    def get_title
      @feed.title
    end

    def parse(url)
      initialize(url)
    end

    def process_feeds
      create_leaflet(@feed)
    end

    private

    def create_leaflet(feed)
      if feed.respond_to?(:entries)
        feed.entries.each do |entry|
          unless Leaflet.where(identifier: entry.entry_id).exists?
            content = entry.summary
            if content.blank?
              content = entry.content
              if content.blank?
                content = "Could not retrive data!"
              end
            end

            if entry.respond_to?(:image)
              image = entry.image
            elsif entry.respond_to?(:itunes_image)
              image = entry.itunes_image
            else
              image = nil
            end

            if entry.entry_id.nil?
              ident = Digest::MD5.hexdigest(entry.url + entry.title).to_s
              return if Leaflet.where(identifier: ident).exists?
            else
              ident = entry.entry_id
            end

            channel = Channel.find_by(source: @url)
            Leaflet.create!(channel_id: channel.id,
                            identifier: ident,
                            title: entry.title,
                            url: entry.url,
                            author: entry.author,
                            image: image,
                            content: content,
                            published_at: entry.published)
          end
        end
      end
    end

  end
end
