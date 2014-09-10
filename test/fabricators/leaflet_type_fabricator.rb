Fabricator(:leaflet_type) do
  leaflet_type { sequence(:leaflet_type) { |i| "lt_#{i}" } }
  leaflet_type_desc { sequence(:leaflet_type_desc) { |i| "lt_desc_#{i}" } }
end