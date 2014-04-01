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
end
