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

  class Spike
    require 'uri'
    require 'nokogiri'
    require 'curb'
    
    LINK_TYPE = ['application/rss+xml', 'application/atom+xml']
    XML_NAME = ['rss', 'feed']

    def self.detect_title(url)
      count = 0
      curl = Curl::Easy.new
      curl.follow_location = true
      curl.url = url
      begin
        curl.perform
        title = Nokogiri::HTML(curl.body).title
      rescue Curl::Err::HostResolutionError, Curl::Err::ConnectionFailedError
        count += 1
        p "Reconnecting..."
        retry unless count > 5
        p "Aborting! Can't connect to " + url.to_s
      end
      if title.nil? || title.blank?
        uri = URI.parse(url)
        if uri.path.blank?
          p url.to_s
        else
          uri.path = ""
          detect_title(uri.to_s)
        end
      else
        p title
      end
    end

    def self.detect_feed(url)
      count = 0
      feed_urls = []
      curl = Curl::Easy.new
      curl.follow_location = true
      curl.url = url
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
        p feed_urls
      rescue Curl::Err::HostResolutionError, Curl::Err::ConnectionFailedError
        count += 1
        p "Reconnecting..."
        retry unless count > 5
        p "Aborting! Can't connect to " + url.to_s
      end
    end
  end
end
