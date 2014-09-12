module ApplicationHelper

  def title(page_title)
    content_for :title, page_title.to_s
  end

  def sanitize_leaflet_content(content)
    content = reddit_content.gsub(/<a href=\"\/r\//, '<a href="http://reddit.com/r/')
    content = content.gsub(/<a href=\"\/u\//, '<a href="http://reddit.com/u/')
    content = content.gsub(/img src=http:\/\/b.thumbs.redditmedia.com/, 'img class="reddit-thumbnail" src=http://b.thumbs.redditmedia.com')
    content = content.gsub(/img src=http:\/\/a.thumbs.redditmedia.com/, 'img class="reddit-thumbnail" src=http://a.thumbs.redditmedia.com')
    content = content.gsub(/\<img src=default \/\>/, '')
    content
  end

end
