class Rake < ActiveRecord::Base
  after_create :create_channel #, :inherit_channels
  attr_accessor :feed_leaflets
  attr_accessor :rake_filters
  attr_accessor :leaflet_id
  attr_accessor :leaflet_type_id
  attr_accessor :leaflet_title
  attr_accessor :leaflet_desc
  attr_accessor :leaflet_url
  attr_accessor :heap_id
  attr_accessor :category_id
  attr_accessor :created_by

  validates :name, presence: true
  validates :master_rake_id, presence: true
  validates :user_id, presence: true

  belongs_to :master_rake
  belongs_to :user

  has_many :rake_channel_maps, dependent: :destroy
  has_many :channels, through: :rake_channel_maps, dependent: :destroy
  has_many :filters, dependent: :destroy
  has_many :heaps, dependent: :destroy


  def add_channel(channel)
    self.rake_channel_maps.create(channel_id: channel.id)
    MasterRake.find(self.master_rake_id).add_channel(channel)
  end

  def remove_channel(channel)
    self.rake_channel_maps.find_by(channel_id: channel.id).destroy
  end

  def toggle_channel_display(channel, display)
    self.rake_channel_maps.find_by(channel_id: channel.id).update!(display: display)
  end

  def feed_leaflets(feed_type, refresh)
    filter_array = self.filters.map { |f| f.keyword }
    filter_array = filter_array.map { |val| "%#{val}%" }
    if refresh == "yes"
      self.channels.each do |c|
        if c.last_pull_at < Time.now - 1200
          begin
            c.pull_source
          rescue
          end
        end
      end
    end
    rake_channel_id = self.channels.map{ |r| (r.source == self.id.to_s) ? r.id : nil }.compact.first
    if self.refreshed_at.nil?
      if !filter_array.empty?
        feed_leaflets = Leaflet.where("channel_id IN (?) AND content ILIKE ANY ( array[?] )", 
                        self.rake_channel_maps.map{ |rc| ((rc.display == true) && (rc.channel_id != rake_channel_id)) ? rc.channel_id : nil}.compact, filter_array)
      else
        feed_leaflets = Leaflet.where("channel_id IN (?)", 
                        self.rake_channel_maps.map{ |rc| ((rc.display == true) && (rc.channel_id != rake_channel_id)) ? rc.channel_id : nil}.compact)
      end
    else
      if !filter_array.empty?
        feed_leaflets = Leaflet.where("channel_id IN (?) AND created_at >= '#{self.refreshed_at}' AND content ILIKE ANY ( array[?])", 
                        self.rake_channel_maps.map{ |rc| ((rc.display == true) && (rc.channel_id != rake_channel_id)) ? rc.channel_id : nil}.compact, filter_array)
      else
        feed_leaflets = Leaflet.where("channel_id IN (?) AND created_at >= '#{self.refreshed_at}'", 
                        self.rake_channel_maps.map{ |rc| ((rc.display == true) && (rc.channel_id != rake_channel_id)) ? rc.channel_id : nil}.compact)
      end
    end
    # rake_ids = User.find(self.user_id).rakes.map(&:id)
    # old_feed_leaflets = Feed.where("rake_id IN (?)", rake_ids)
    # delete_feed_leaflets_ids = old_feed_leaflets.pluck(:id) - feed_leaflets.pluck(:id)
    # delete_feed_leaflets = Feed.where("id IN (?)", delete_feed_leaflets_ids)
    # delete_feed_leaflets.each do |f|
    #   f.destroy
    # end

    # feed_leaflets.each do |f|
    #   if Feed.where(rake_id: self.id).find_by_leaflet_id(f.id).nil?
    #     Feed.create!(rake_id: self.id, leaflet_id: f.id, status: 0)
    #   end
    # end
  end

  def add_leaflet(leaflet, leaflet_type_id, leaflet_title, leaflet_desc)
    if self.heaps.where("leaflet_type_id = ?", leaflet_type_id).empty?
      self.add_heap(leaflet_type_id)
    end
    self.heaps.find_by_leaflet_type_id(leaflet_type_id).add_leaflet(leaflet, leaflet_type_id, leaflet_title, leaflet_desc)
  end

  def create_leaflet(leaflet_type_id, leaflet_title, leaflet_desc, leaflet_url)
    channel_id = self.channels.where("channel_type = 3").first.id
    leaflet = Leaflet.create(leaflet_type_id: leaflet_type_id,
                             title: leaflet_title,
                             url: leaflet_url,
                             channel_id: channel_id,
                             content: leaflet_desc,
                             created_by: self.user_id,
                             published_at: Time.now)
    self.add_leaflet(leaflet, leaflet_type_id, leaflet_title, leaflet_desc)
  end

  def add_heap(leaflet_type_id)
    self.heaps.create(rake_id: self.id, leaflet_type_id: leaflet_type_id)
  end

  def get_heap
    self.heap.leaflets
  end

  def add_filter(keyword, filter_type)
    self.filters.create(keyword: keyword, filter_type: filter_type)
  end

  private

  def create_channel
    add_channel(Channel.create!(source: id.to_s, name: name, channel_type: 3))
  end

  def inherit_channels
    MasterRake.find(self.master_rake_id).channels.each { |channel| add_channel(channel) unless channel.channel_type == 5 }
  end

end
