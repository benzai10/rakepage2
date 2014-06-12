ActiveAdmin.register CategoryLeafletTypeMap do
  permit_params :category_id, :leaflet_type_id

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
    column :category do |c|
      desc = Category.find(c.id).desc
    end
    column :leaflet_type do |l|
      type = LeafletType.find(l.id).leaflet_type
    end
    column :leaflet_type_desc do |l|
      desc = LeafletType.find(l.id).leaflet_type_desc
    end
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "Category LeafletType Map" do
      f.input :category_id
      f.input :leaflet_type_id
    end
    f.actions
  end

end
