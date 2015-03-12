ActiveAdmin.register Channel do
  permit_params :name, :channel_type, :source, :public_channel

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
    column :name
    column :source
    column :channel_type
    column :created_at
    column :updated_at
    column :last_pull_at
    column :public_channel
    actions
  end
end
