# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
AdminUser.create(email: "admin@example.com", password: "password")
User.create(email: "example@example.com", username: "example_user", password: "password")
User.create(email: "example2@example.com", username: "example_user2", password: "password")

linux = MasterRake.create!(name: "Linux")
linux.add_channel(Channel.create(source: "http://inconsolation.wordpress.com/feed", channel_type: 0))
linux.add_channel(Channel.create(source: "http://www.lxer.com", channel_type: 0))
linux.add_channel(Channel.create(source: "http://www.phoronix.com/rss.php", channel_type: 0))
linux.add_channel(Channel.create(source: "http://planet.freedesktop.org/atom.xml", channel_type: 0))
linux.add_channel(Channel.create(source: "http://www.linuxtoday.com/biglt.rss", channel_type: 0))
linux.add_channel(Channel.create(source: "linux/new", channel_type: 4))

tech = MasterRake.create!(name: "Technology")
tech.add_channel(Channel.create(source: "http://www.techcrunch.com/feed", channel_type: 0))
tech.add_channel(Channel.create(source: "http://www.theverge.com/rss/index.xml", channel_type: 0))
tech.add_channel(Channel.create(source: "http://feeds.gawker.com/gizmodo/full", channel_type: 0))
tech.add_channel(Channel.create(source: "http://www.zdnet.com/rss.xml", channel_type: 0))
tech.add_channel(Channel.create(source: "http://rss.slashdot.org/Slashdot/slashdot", channel_type: 0))
tech.add_channel(Channel.create(source: "http://www.techcrunch.com/", channel_type: 0))

webdev = MasterRake.create!(name: "Web Development")
webdev.add_channel(Channel.create(source: "http://feeds.feedburner.com/dailyjs", channel_type: 0))
webdev.add_channel(Channel.create(source: "http://davidwalsh.name/feed/atom", channel_type: 0))
webdev.add_channel(Channel.create(source: "http://www.labnol.org", channel_type: 0))
webdev.add_channel(Channel.create(source: "http://feeds.feedburner.com/johnresig", channel_type: 0))
webdev.add_channel(Channel.create(source: "http://feeds.feedburner.com/Webappers", channel_type: 0))
webdev.add_channel(Channel.create(source: "http://afreshcup.com/home/atom.xml", channel_type: 0))
webdev.add_channel(Channel.create(source: "rails/new", channel_type: 4))
