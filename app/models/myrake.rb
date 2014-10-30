class Myrake < ActiveRecord::Base
  require 'mechanize'
  after_create :create_channel #, :inherit_channels
  attr_accessor :feed_leaflets
  attr_accessor :rake_filters
  attr_accessor :leaflet_id
  attr_accessor :leaflet_type_id
  attr_accessor :leaflet_title
  attr_accessor :leaflet_desc
  attr_accessor :leaflet_url
  attr_accessor :leaflet_goal
  attr_accessor :leaflet_note
  attr_accessor :reminder_at
  attr_accessor :heap_id
  attr_accessor :category_id
  attr_accessor :created_by
  attr_accessor :leaflet_errors
  attr_accessor :current_user
  attr_accessor :copy_recommendations
  attr_accessor :current_score
  attr_accessor :current_reminder
  attr_accessor :collapse

  validates :name, presence: true
  validates :master_rake_id, presence: true
  #validates :master_rake_id, uniqueness: true, :if => :is_current_user?
  validates :user_id, presence: true

  belongs_to :master_rake
  belongs_to :user

  has_many :rake_channel_maps, dependent: :destroy
  has_many :channels, through: :rake_channel_maps, dependent: :destroy
  has_many :filters, dependent: :destroy
  has_many :heaps, dependent: :destroy

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  def url_data(url)
    url_hash = {leaflet_title: "", leaflet_desc: ""}
    agent = Mechanize.new
    if !agent.nil?
      begin
        agent.get(url)
        url_hash[:leaflet_title] = agent.page.title
        if !agent.page.at("head meta[name='description']").nil?
          url_hash[:leaflet_desc] = agent.page.at("head meta[name='description']").attributes["content"].value
        else
          url_hash[:leaflet_desc] = ""
        end
      rescue
        url_hash[:leaflet_title] = ""
        url_hash[:leaflet_desc] = ""
      end
    else
      url_hash[:leaflet_title] = ""
      url_hash[:leaflet_desc] = ""
    end
    url_hash
  end

  def is_current_user?
    current_user
  end

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
        #if c.last_pull_at < Time.now - 00 || c.channel_type == 3 
          begin
            self.update_attributes(refreshed_at: Time.now)
            c.pull_source
          rescue
          end
        #end
      end
    end
    rake_channel_id = self.channels.map{ |r| (r.source == self.id.to_s) ? r.id : nil }.compact.first
    # if self.refreshed_at.nil?
    #   if !filter_array.empty?
    #     feed_leaflets = Leaflet.where("channel_id IN (?) AND content ILIKE ANY ( array[?] )", 
    #                     self.master_rake.channels.where(channel_type: 3).pluck(:id) + self.rake_channel_maps.map{ |rc| ((rc.display == true) && (rc.channel_id != rake_channel_id)) ? rc.channel_id : nil}.compact, filter_array)
    #   else
    #     feed_leaflets = Leaflet.where("channel_id IN (?)", 
    #                     self.master_rake.channels.where(channel_type: 3).pluck(:id) + self.rake_channel_maps.map{ |rc| ((rc.display == true) && (rc.channel_id != rake_channel_id)) ? rc.channel_id : nil}.compact)
    #   end
    # else
    #   if !filter_array.empty?
    #     feed_leaflets = Leaflet.where("channel_id IN (?) AND created_at >= '#{self.refreshed_at}' AND content ILIKE ANY ( array[?])", 
    #                     self.master_rake.channels.where(channel_type: 3).pluck(:id) + self.rake_channel_maps.map{ |rc| ((rc.display == true) && (rc.channel_id != rake_channel_id)) ? rc.channel_id : nil}.compact, filter_array)
    #   else
    #     feed_leaflets = Leaflet.where("channel_id IN (?) AND created_at >= '#{self.refreshed_at}'", 
    #                     self.master_rake.channels.where(channel_type: 3).pluck(:id) + self.rake_channel_maps.map{ |rc| ((rc.display == true) && (rc.channel_id != rake_channel_id)) ? rc.channel_id : nil}.compact)
    #   end
    # end
    feed_leaflets = Leaflet.where("channel_id IN (?)", 
                    self.master_rake.channels.where(channel_type: 3).pluck(:id) + self.rake_channel_maps.map{ |rc| ((rc.display == true) && (rc.channel_id != rake_channel_id)) ? rc.channel_id : nil}.compact)
  end

  def add_leaflet(leaflet,
                  leaflet_type_id,
                  leaflet_title,
                  leaflet_desc,
                  leaflet_goal,
                  leaflet_note,
                  reminder,
                  current_score,
                  current_reminder)
    if self.heaps.where("leaflet_type_id = ?", leaflet_type_id).empty?
      self.add_heap(leaflet_type_id)
    end
    if self.heaps.find_by_leaflet_type_id(leaflet_type_id).add_leaflet(leaflet,
                                                                       leaflet_type_id,
                                                                       leaflet_title,
                                                                       leaflet_desc,
                                                                       leaflet_goal,
                                                                       leaflet_note,
                                                                       reminder,
                                                                       current_score,
                                                                       current_reminder)
      master_heap = MasterHeap.where(master_rake_id: self.master_rake_id, leaflet_type_id: leaflet_type_id).first
      if !master_heap.nil?
        MasterHeapLeafletMap.create(master_heap_id: master_heap.id, leaflet_id: leaflet.id, leaflet_desc: leaflet_desc)
      end
    else
      self.leaflet_errors = leaflet.errors
      nil
    end
  end

  def create_leaflet(leaflet_type_id,
                     leaflet_title,
                     leaflet_desc,
                     leaflet_goal,
                     leaflet_note,
                     leaflet_url,
                     leaflet_author,
                     reminder,
                     current_score,
                     current_reminder)
    channel_id = self.channels.where("channel_type = 3").first.id
    leaflet = Leaflet.create(leaflet_type_id: leaflet_type_id,
                             title: leaflet_title,
                             url: leaflet_url,
                             channel_id: channel_id,
                             content: leaflet_desc,
                             author: leaflet_author,
                             created_by: self.user_id,
                             published_at: Time.now)
    if leaflet.valid?
      self.add_leaflet(leaflet,
                       leaflet_type_id,
                       leaflet_title,
                       leaflet_desc,
                       leaflet_goal,
                       leaflet_note,
                       reminder,
                       current_score,
                       current_reminder)
      leaflet.id
    else
      self.leaflet_errors = leaflet.errors
      nil
    end
  end

  def add_heap(leaflet_type_id)
    self.heaps.create(myrake_id: self.id, leaflet_type_id: leaflet_type_id)
  end

  def get_heap
    self.heap.leaflets
  end

  def self.get_leaflets(rake_id)
    leaflets = []
    self.find(rake_id).heaps.each do |h|
      h.leaflets.each do |l|
        if l.created_by == self.find(rake_id).user_id
          leaflets << l
        end
      end
    end
    return leaflets
  end

  def add_filter(keyword, filter_type)
    self.filters.create(keyword: keyword, filter_type: filter_type)
  end

  private

  def slug_candidates
    [
      :name,
      [:name, :user_id],
    ]
  end

  def create_channel
    add_channel(Channel.create!(source: id.to_s, name: name, channel_type: 3))
  end

  def inherit_channels
    MasterRake.find(self.master_rake_id).channels.each { |channel| add_channel(channel) unless channel.channel_type == 5 }
  end

end
