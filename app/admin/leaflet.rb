ActiveAdmin.register Leaflet do
  permit_params :content, :channel_id

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
    column :identifier
    column :content
    column :channel
    column :published_at
    column :created_at
    column :updated_at
    actions
  end
end