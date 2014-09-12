namespace :rakepage_tests do

  desc "Check if all rakes have a heap 'Uncategorized'"
  task :check_uncategorize_heaps => :environment do
    Myrake.all.each do |r|
      print "Checking rake id: " + r.id.to_s + "\n"
      if r.heaps.pluck(:leaflet_type_id).include? 1
        print "Rake has a 'Uncategorized' Heap\n"
      else
        print "Rake has NOT a 'Uncategorized' Heap!\n"
      end
    end
  end

  desc "Check if all master rakes have a heap 'Uncategorized'"
  task :check_uncategorize_master_heaps => :environment do
    MasterRake.all.each do |r|
      print "Checking master rake id: " + r.id.to_s + "\n"
      if r.master_heaps.pluck(:leaflet_type_id).include? 1
        print "Master Rake has a 'Uncategorized' Heap\n"
      else
        print "Master Rake has NOT a 'Uncategorized' Heap!\n"
      end
    end
  end

  desc "Adding a new leaflet_type to a category"
  task :add_leaflet_type_to_category => :environment do
    puts "\n Enter a Leaflet Type Id (make sure it exists!)"
    leaflet_type_id = STDIN.gets.chomp
    added_leaflet_type = LeafletType.find(leaflet_type_id.to_i)
    puts "\n Enter the Category Id you want the Leaflet Type added to (make sure, the category exists!)"
    category_id = STDIN.gets.chomp
    category = Category.find(category_id.to_i)
    if category.add_leaflet_type(added_leaflet_type)
      puts "\n Leaflet Type was added to Category!"
      MasterRake.where(category_id: category.id).each do |mr|
        mr.add_master_heap(added_leaflet_type.id)
        puts "\n Master Heap added to MR id: " + mr.id.to_s
      end
      puts "\n All master heaps created"
    else
      puts "\n Category matching failed!"
      return false
    end
  end

  desc "Sanitize all leaflet content"
  task :sanitize_leaflet_contents => :environment do
    start_time = Time.now
    Leaflet.all.each_with_index do |l, i|
      if i % 1000 == 0
        puts "\nProcessing: " + i.to_s
      end
      # content = l.content.gsub(/\<a href=["'](.*?)["']\>(.*?)\<\/a\>/mi, '<a href="\1" target="_blank" >\2</a>')
      content = l.content
      if content.include? "width=\"1\" height=\"1\""
        content = content.gsub(/<img alt[()\s\S]*?\/>/mi, '')
      end
      content = content.gsub(/<a href=\"\/r\//, '<a href="http://reddit.com/r/')
      content = content.gsub(/<a href=\"\/u\//, '<a href="http://reddit.com/u/')
      content = content.gsub(/img src=http:\/\/b.thumbs.redditmedia.com/, 'img class="reddit-thumbnail" src=http://b.thumbs.redditmedia.com')
      content = content.gsub(/img src=http:\/\/a.thumbs.redditmedia.com/, 'img class="reddit-thumbnail" src=http://a.thumbs.redditmedia.com')
      content = content.gsub(/\<img src=default \/\>/, '')
      content = content.gsub(/\<img src=self \/\>/, '')
      l.update_attributes(content: content)
    end
    end_time = Time.now
    puts "Time elapsed: " + (end_time - start_time).to_s
  end

  desc "Test sending an email"
  task :send_test_email => :environment do
    UserMailer.welcome_email.deliver
  end

  desc "Delete unused leaflet_ids from HeapLeafletMap and MasterHeapLeafletMap"
  task :delete_heap_leaflets => :environment do
    HeapLeafletMap.all.each do |hlm|
      l = Leaflet.where(id: hlm.leaflet_id).first
      if l.nil?
        print "Leaflet id: " + hlm.leaflet_id.to_s + " destroyed in Heap: " + hlm.heap_id.to_s + "\n"
        hlm.destroy
      end
    end
    MasterHeapLeafletMap.all.each do |mhlm|
      l = Leaflet.where(id: mhlm.leaflet_id).first
      if l.nil?
        print "Leaflet id: " + mhlm.leaflet_id.to_s + " destroyed in Master Heap: " + mhlm.master_heap_id.to_s + "\n"
        mhlm.destroy
      end
    end
  end

end