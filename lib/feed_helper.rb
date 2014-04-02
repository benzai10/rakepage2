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
        p "No  feed is nil!"
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

            if entry.summary.blank?
              content = entry.content
            elsif
              content = entry.summary
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

    def initialize
      @count=0
    end

    def detect_title(url)
      title = String.new
      begin
        title = Nokogiri::HTML(Curl.get(url).body).title ||= "No title available"
      rescue
        reconnect(0,url)
      end
      title
    end

    def chd
      Channel.all.each do |channel|
        title(channel.source)
        detect(channel.source)
      end
      return nil
    end

    def detect_feed(url)
      begin
        feed_urls = []
        Nokogiri::HTML(Curl.get(url).body).css('link').each do |link|
          if link.attribute("type").respond_to?(:value) && (link.attribute("type").value.include?("rss") || link.attribute("type").value.include?("atom"))
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
        feed_urls
      rescue Curl::Err::HostResolutionError
        reconnect(1,url)
      end
    end

    private

    def reconnect(func,url)
      if @count < 5
        p "Reconnecting..."
        @count += 1
        if func == 0
          self.title(url)
        elsif func == 1
          self.detect(url)
        end
      else
        p "Aborting! Can't get " + url.to_s
        @count = 0
        return
      end
    end
  end

end
