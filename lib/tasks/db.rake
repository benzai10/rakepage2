namespace :rakepage_migration do

  desc "Change page titles"
  task :change_page_titles => :environment do
    MasterRake.all.each do |mr|
      mr.update_attributes(seo_title: "#{mr.name}")
    end
  end

  desc "Change page descriptions"
  task :change_page_descriptions => :environment do
    MasterRake.all.each do |mr|
      mr.update_attributes(description: "#{mr.name} | Focus On Your Essentials")
    end
  end

  desc "Create heaps for each master rake"
  task :create_master_rake_heaps => :environment do
    master_rake_count = 0
    MasterRake.all.each do |mr|
      master_rake_count += 1
      category_count = 0
      CategoryLeafletTypeMap.where(category_id: mr.category_id).each do |c|
        category_count += 1
        MasterHeap.create(master_rake_id: mr.id, leaflet_type_id: c.leaflet_type_id)
      end
      print "Master rake " + mr.id.to_s + ": " + category_count.to_s + " heaps created.\n"
    end
    print "Heaps for " + master_rake_count.to_s + " master rakes created!\n"
  end

  desc "Create leaflets for the master rake heaps based on existing heap leaflets in rakes"
  task :create_master_rake_leaflets => :environment do
    print "HeapLeafletMap records: " + HeapLeafletMap.count.to_s + "\n"
    processed = 0
    duplicates = 0
    HeapLeafletMap.all.each do |hlm|
      master_heap = MasterHeap.where(master_rake_id: hlm.heap.myrake.master_rake_id, 
                                     leaflet_type_id: hlm.leaflet_type_id).first
      if !master_heap.nil?
        begin
          MasterHeapLeafletMap.create!(master_heap_id: master_heap.id, 
                                      leaflet_id: hlm.leaflet_id, 
                                      leaflet_desc: hlm.leaflet_desc)
          processed += 1
        rescue
          duplicates += 1
        end
      else
        print "HeapLeafletMap id: " + hlm.id.to_s + " with leaflet_type_id " + hlm.leaflet_type_id.to_s + " couldn't be found or processed.\n"
      end
    end
    print "Successfully processed HeapLeafletMap records: " + processed.to_s + "\n"
    print "Duplications not processed: " + duplicates.to_s + "\n"
  end
end