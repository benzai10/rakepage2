ActiveAdmin.register Notification do
  permit_params :title, :subtitle, :body, :notification_type, :icon, :published_at, :user_ids, :master_rake_ids

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
    column :title
    column :subtitle
    column :body
    column :notification_type
    column :icon
    column :master_rake_ids
    column :user_ids
    column :published_at
    column :updated_at
    column :created_at
    column :refreshed_at
    actions
  end
end