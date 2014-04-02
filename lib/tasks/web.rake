namespace :web do

  desc "Delete all leaflets in db"
  task :crush_leaflets => :environment do
    print Leaflet.delete_all
    print " Leaflets crushed!\n"
  end

  desc "Get all exisiting feed from all channels"
  task :get_feeds => :environment do

    require 'feed_helper'

    feeds = Feedjira::Feed.fetch_and_parse FeedHelper::Web.get_channel_feeds
    FeedHelper::Web.process_feeds(feeds)
  end

end
