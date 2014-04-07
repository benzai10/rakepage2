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
            count += 1
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
    require 'addressable/uri'
    require 'curb'
    require 'logger'
    require 'nokogiri'

    @@logger = Logger.new("log/feed_helper.log")
    @@logger.progname = 'Spike'

    LINK_TYPE = ['application/rss+xml', 'application/atom+xml']
    XML_NAME = ['rss', 'feed']

    DEBUG_MSG_ABORT = "- Aborting can't connect to: "
    DEBUG_MSG_PARAM = " - Parameter: "
    DEBUG_MSG_RECONNECTING = "Reconnecting..."
    MSG_NO_TITLE = "Title not available."

    def initialize(url)
      @url = parse_link(url)
      @html=get_html(@url)
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

    private

    def get_html(url)
      count = 1
      curl = Curl::Easy.new
      curl.follow_location = true
      curl.url = url
      begin
        curl.perform
        @html = curl.body
      rescue Curl::Err::HostResolutionError, Curl::Err::ConnectionFailedError
        count += 1
        p DEBUG_MSG_RECONNECTING + url
        retry unless count > 5
        p DEBUG_MSG_ABORT
        @@logger.debug DEBUG_MSG_ABORT + url
      rescue Exception => e
        p e.message
        @@logger.error + e.message + DEBUG_MSG_PARAM + url
      end
    end

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

end
