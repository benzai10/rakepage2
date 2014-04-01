namespace :web do

  desc "Delete all leaflets in db"
  task :crush_leaflets => :environment do
    print Leaflet.delete_all
    print " Leaflets crushed!\n"
  end

  desc "Get all exisiting feed from all channels"
  task :get_feeds => :environment do

    require 'feedjira'
    require 'feed_helper'

    feeds = Feedjira::Feed.fetch_and_parse FeedHelper::Web.get_feeds
    FeedHelper::Web.process_feed(feeds)
  end

end
