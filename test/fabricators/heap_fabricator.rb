Fabricator(:heap) do
  myrake
  leaflet_type_id { sequence(:leaflet_type_id) { |i| "#{i}".to_i } }
end