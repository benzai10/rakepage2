namespace :web do


  desc "TODO"
  task :get_feeds => :environment do

    require 'feedjira'

    urls = []
    channels=Channel.where(channel_type: "rss").each do |channel|
      urls << channel.source
    end

    feeds = Feedjira::Feed.fetch_and_parse urls
    feeds.each do |url,feed|
      feed.entries.each do |entry|
        channel = Channel.find_by(source: url)
        Leaflet.create!(channel_id: channel.id, content: entry.summary, published_at: entry.published)
      end
    end

  end
end
