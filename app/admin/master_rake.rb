ActiveAdmin.register MasterRake do
  permit_params :name, :seo_title, :description, :created_by, :category_id, :wikipedia_url, :wikipedia_first_paragraph, :image_url, :featured, :slug

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

  form do |f|
    f.inputs "MasterRake" do
      f.input :name
      f.input :seo_title
      f.input :description
      f.input :created_by
      f.input :category_id
      f.input :wikipedia_url
      f.input :wikipedia_first_paragraph
      f.input :image_url
      f.input :featured
      f.input :slug
    end
    f.actions
  end

end
