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
end