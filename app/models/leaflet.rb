class Leaflet < ActiveRecord::Base
  before_create :sanitize_content
  attr_accessor :rake_id
  attr_accessor :leaflet_desc

  validates :channel_id, presence: true
  validates :url, :format => URI::regexp(%w(http https))
  validates :leaflet_type_id, presence: true
  validates :title, length: { minimum: 3 }

  belongs_to :channel
  has_many :feeds, dependent: :destroy

  scope :newly_added, -> { where.not(leaflet_type_id: 15).where.not(save_count: 0).order(created_at: :desc).limit(50) }

  protected

  def sanitize_content
    content = self.content.gsub(/\<a href=["'](.*?)["']\>(.*?)\<\/a\>/mi, '<a href="\1" target="_blank" >\2</a>')
    content = content.gsub(/<a href=\"\/r\//, '<a href="http://reddit.com/r/')
    content = content.gsub(/<a href=\"\/u\//, '<a href="http://reddit.com/u/')
    content = content.gsub(/img src=http:\/\/b.thumbs.redditmedia.com/, 'img class="reddit-thumbnail" src=http://b.thumbs.redditmedia.com')
    content = content.gsub(/img src=http:\/\/a.thumbs.redditmedia.com/, 'img class="reddit-thumbnail" src=http://a.thumbs.redditmedia.com')
    content = content.gsub(/\<img src=default \/\>/, '')
    content = content.gsub(/\<img src=self \/\>/, '')
    if (content.include? "width=\"1\"") or 
       (content.include? "height=\"1\"") or
       (content.include? "width=\'1\'") or
       (content.include? "width=\'1\'")
      #img_match = content.match(/.*(<img [\s\S]*?\/>)/mi)
      #if !img_match.nil?
      #  content.slice! img_match.captures.last
      #else
      #  content = content.gsub(/<img [()\s\S]*?\/>/mi, '')
      #end
      content = content.gsub(/<img[^>]+\>/mi, '')
    end
    if content.include? "new.livestream.com"
      content = ""
    end
    self.content = content
  end
end
