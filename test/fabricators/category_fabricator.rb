Fabricator(:category) do
  leaflet_types(count: 5)
  desc { sequence(:desc) { |i| "Category #{i}" } }
end