ActiveAdmin.register Myrake do
  permit_params :name, :master_rake_id, :user_id

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
    column :master_rake
    column :user
    column :heap
    column :updated_at
    column :created_at
    column :refreshed_at
    actions
  end
end