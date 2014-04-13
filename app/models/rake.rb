class Rake < ActiveRecord::Base
  after_create :create_heap, :create_channel, :inherit_channels
  attr_accessor :feed_leaflets

  validates :name, presence: true
  validates :master_rake_id, presence: true
  validates :user_id, presence: true

  belongs_to :master_rake
  belongs_to :user

  has_many :rake_channel_maps, dependent: :destroy
  has_many :channels, through: :rake_channel_maps, dependent: :destroy
  has_one :heap, dependent: :destroy

  def add_channel(channel)
    self.rake_channel_maps.create(channel_id: channel.id)
  end

  def remove_channel(channel)
    self.rake_channel_maps.find_by(channel_id: channel.id).destroy
  end

  def toggle_channel_display(channel, display)
    self.rake_channel_maps.find_by(channel_id: channel.id).update!(display: display)
  end

  def feed_leaflets(feed_type)
    if feed_type == "saved"
      leaflet_ids = []
      self.master_rake.rakes.each do |r|
        leaflet_ids << r.heap.leaflets.pluck(:id)
      end
      leaflet_ids = leaflet_ids.flatten.uniq
      leaflet_ids = leaflet_ids - self.heap.leaflets.pluck(:id)
      #if self.saved_refreshed_at.nil?
        feed_leaflets = Leaflet.where("id IN (?)", leaflet_ids)
      #else
      #  feed_leaflets = Leaflet.where("id IN (?) AND updated_at >= '#{self.saved_refreshed_at}'", leaflet_ids)
      #end
    else
      #if self.refreshed_at.nil?
        feed_leaflets = Leaflet.where("channel_id IN (?)", 
                        self.rake_channel_maps.map{ |rc| (rc.display == true) ? rc.channel_id : nil}.compact)
      #else
      #  feed_leaflets = Leaflet.where("channel_id IN (?) AND created_at >= '#{self.refreshed_at}'", 
      #                  self.rake_channel_maps.map{ |rc| (rc.display == true) ? rc.channel_id : nil}.compact)
      #end
      #feed_leaflets = temp.where("id NOT IN (?)", self.heap.leaflets.pluck(:id))
    end
  end

  def get_heap
    self.heap.leaflets
  end

  private

  def create_heap
    self.heap = Heap.create
  end

  def create_channel
    add_channel(Channel.create!(source: id.to_s, name: name, channel_type: 3))
  end

  def inherit_channels
    MasterRake.find(self.master_rake_id).channels.each { |channel| add_channel(channel) }
  end

end
