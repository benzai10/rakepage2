ActiveAdmin.register RakeChannelMap do
  permit_params :rake_id, :channel_id, :options

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
    column :options
    column :rake
    column :channel
    column :created_at
    column :updated_at
    actions
  end
end
