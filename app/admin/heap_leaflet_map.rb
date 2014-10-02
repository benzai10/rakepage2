ActiveAdmin.register HeapLeafletMap do
  permit_params :heap_id, :leaflet_id

  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

  index do
    selectable_column
    id_column
    column :heap_id
    column :leaflet_id
    column :leaflet_title
    column :reminder_at
    column :created_at
    column :updated_at
    actions
  end
end
