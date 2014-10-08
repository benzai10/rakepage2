base_url = "http://#{request.host_with_port}"
xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url{
      xml.loc("http://rakepage.com")
      xml.changefreq("weekly")
      xml.priority(1.0)
  }
  xml.url{
      xml.loc("http://rakepage.com/master_rakes")
      xml.changefreq("daily")
      xml.priority(0.9)
  }
  @master_rakes.each do |mr|
    xml.url {
      xml.loc("http://rakepage.com/#{mr.slug}")
      xml.changefreq("weekly")
      xml.priority(0.5)
    }
  end
end