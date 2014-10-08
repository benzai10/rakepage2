Rakepage2::Application.routes.draw do
  root to: "pages#landing"
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => { :registrations => "registrations" }

  #match 'pages/help', to: 'pages#help', via: [:get]

  resources :sitemaps, :only => :show
  get "sitemap" => "sitemaps#show"

  resources :charts do
    member do
      get 'recommendation_activity'
    end
  end

  resources :histories

  resources :pages

  resources :users do
    member do
      get 'save_leaflet'
      get 'edit_leaflet'
    end
  end

  resources :channels do
    member do
      get 'refresh_feed'
    end
    collection do
      get :autocomplete_channel_source
    end
  end

  resources :heaps do
    member do
      get 'add_leaflet'
      get 'remove_leaflet'
    end
  end

  resources :leaflets do
    collection do
      post 'view_add'
      post 'like_add'
    end
  end

  resources :master_rakes do
    member do
      get 'add_channel'
      get 'remove_channel'
      get 'toggle_channel_display'
    end
    collection do
      get 'search'
      get :autocomplete_master_rake_name
      get 'add_rake'
      post 'add_rake'
    end
  end

  resources :myrakes do
    member do
      get 'get_url_title'
      get 'add_channel'
      get 'remove_channel'
      get 'add_leaflet'
      get 'update_filter'
      get 'toggle_channel_display'
      get 'news'
      get 'saved'
    end
    collection do
      get 'search'
      get :autocomplete_myrake_name
    end
  end

  resources :authentications do
    collection do
      get 'connect_facebook'
      get 'connect_twitter'
    end
  end

  match 'auth/:provider/callback', to: 'authentications#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
