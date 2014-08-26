namespace :rakepage_migration do

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
                                     leaflet_type_id: hlm.leaflet_type_id)
      if !master_heap.empty?
        begin
          MasterHeapLeafletMap.create!(master_heap_id: master_heap.id, 
                                      leaflet_id: hlm.leaflet_id, 
                                      leaflet_desc: hlm.leaflet_desc)
          processed += 1
        rescue
          duplicates += 1
        end
      else
        print "Master rake " + hlm.heap.myrake.master_rake_id.to_s + " with leaflet_type_id " + hlm.leaflet_type_id.to_s + " couldn't be found.\n"
      end
    end
    print "Successfully processed HeapLeafletMap records: " + processed.to_s + "\n"
    print "Duplications not processed: " + duplicates.to_s + "\n"
  end
end