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
        print "Leaflet id: " + mhlm.leaflet_id.to_s + " destroyed in Master Heap: " + mhlm.heap_id.to_s + "\n"
        mhlm.destroy
      end
    end

  end

end