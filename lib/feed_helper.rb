module FeedHelper

  class Web
    require 'feedjira'

    def self.get_channel_feeds
      urls = []
      Channel.where(channel_type: 0).each do |channel|
        urls << channel.source
      end
      urls
    end

    def self.process_feeds(feeds)
      if feeds.nil?
        p "Aborting! Feed can't be nil."
        return
      end

      count = 0
      feeds.each do |url,feed|
        count += create_leaflet(url,feed)
      end
      print count
      print " Leaflets created\n"
    end

    private

    def self.create_leaflet(url,feed)
      count = 0
      if feed.respond_to?(:entries)
        feed.entries.each do |entry|
          unless Leaflet.where(identifier: entry.entry_id).exists?
            p entry.entry_id
            count+=1
            content = entry.summary
            if content.blank?
              content = entry.content
              if content.blank?
                content = "Could not retrive data!"
              end
            end
            channel = Channel.find_by(source: url)
            Leaflet.create!(channel_id: channel.id,
                            identifier: entry.entry_id,
                            title: entry.title,
                            url: entry.url,
                            author: entry.author,
                            image: entry.image,
                            content: content,
                            published_at: entry.published)
          end
        end
      end
      count
    end
  end

  class Facebook
    require 'koala'
    require 'uri'

    def get_likes(oauth_token)
      liked_pages = []
      url_pages = {}

      graph = Koala::Facebook::API.new(oauth_token)
      user_likes = graph.get_connections("me","likes")

      user_likes.each do |like|
        liked_pages << like["id"]
      end

      pages = graph.batch do |batch_api|
        liked_pages.each do |page|
          batch_api.get_object(page)
        end
      end

      pages.each do |page|
        unless page["website"].nil?
          url_pages[page["name"]] = page["website"].split(%r{[\s,]}).reject(&:empty?)
          #url_pages << page["website"].split(%r{[\s,]}).reject(&:empty?)
        end
      end
      url_pages
    end

  end

  class Spike
    require 'uri'
    require 'nokogiri'
    require 'curb'
    require 'logger'
    require 'rails'

    @logger = Logger.new("feed_helper.log")
    @logger.progname = 'Spike'

    LINK_TYPE = ['application/rss+xml', 'application/atom+xml']
    XML_NAME = ['rss', 'feed']
    DEBUG_MSG_A = "- Aborting can't connect to: "
    DEBUG_MSG_RE = "- Reconnecting to: "
    DEBUG_MSG_P = " - Parameter: "
    DEBUG_MSG_R = "Reconnecting..."

    def self.detect_title(url)
      count = 1
      curl = get_curl(url)
      begin
        curl.perform
        title = Nokogiri::HTML(curl.body).title
      rescue Curl::Err::HostResolutionError, Curl::Err::ConnectionFailedError
        count += 1
        p DEBUG_MSG_R
        retry unless count > 5
         @logger.debug __method__.to_s + DEBUG_MSG_A  + url
         p DEBUG_MSG_A + url
      rescue Exception => e
        @logger.error e.message
        @logger.error __method__.to_s + DEBUG_MSG_P + url
        title = "No title avialable"
      end
      if title.nil? || title.empty?
        uri = URI.parse(url)
        if uri.path.empty? || uri.path == '/'
          p url.to_s
        else
          uri.path = ""
          @logger.debug {__method__.to_s + DEBUG_MSG_RE + uri.to_s }
          detect_title(uri.to_s)
        end
      else
        p title
      end
    end

    def self.detect_feed(url)
      count = 1
      feed_urls = []
      curl = get_curl(url)
      begin
        curl.perform

        if XML_NAME.include? Nokogiri::XML(curl.body).children.first.name
          return p [url]
        end

        Nokogiri::HTML(curl.body).css('link').each do |link|
          if link.attribute("type").respond_to?(:value) && LINK_TYPE.include?(link.attribute("type").value)
            unless feed_urls.include? (link.attribute("href").value)
              if link.attribute("href").value =~ URI::regexp
                feed_urls << link.attribute("href").value
              else
                uri = URI.parse(url)
                uri.path = link.attribute("href").value
                feed_urls << uri.to_s
              end
            end
          end
        end
      rescue Curl::Err::HostResolutionError, Curl::Err::ConnectionFailedError
        count += 1
        p DEBUG_MSG_R
        retry unless count > 5
        p DEBUG_MSG_A
        @logger.debug __method__.to_s + DEBUG_MSG_A  + url
      rescue Exception => e
        @logger.error __method__.to_s + " " + e.message + DEBUG_MSG_P + url
      end
      if feed_urls.empty?
        raise FeedNotFoundError, "Feed not found."
      end
      p feed_urls
    end

    private

    def self.get_curl(url)
      curl = Curl::Easy.new
      curl.follow_location = true
      curl.url = url
      curl
    end

  end

  class FeedNotFoundError < StandardError
  end

end
