namespace :web do

  desc "Delete all leaflets in db"
  task :crush_leaflets => :environment do
    print Leaflet.delete_all
    print " Leaflets crushed!\n"
  end
end
