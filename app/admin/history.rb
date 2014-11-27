ActiveAdmin.register History do
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
    column :user_id
    column :master_rake_id
    column :rake_id
    column :heap_id
    column :channel_id
    column :leaflet_id
    column :user_relation_id
    column :history_code
    column :history_int
    column :history_str
    column :history_int2
    column :history_chain
    column :history_text
    column :created_at
    column :updated_at
    column :created_at
    column :updated_at
    actions
  end
end
