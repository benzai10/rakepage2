Rakepage2::Application.routes.draw do
  root to: "pages#landing"

  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => { :registrations => "registrations" }

  get "sitemap.xml" => "sitemaps#index", as: "sitemap", defaults: { format: "xml" }

  get 'pages/terms_of_service' => 'pages#terms_of_service'
  get 'pages/privacy_policy' => 'pages#privacy_policy'
  get 'pages/about' => 'pages#about'

  # get 'dashboard/index' => 'dashboard#index'
  # get 'dashboard/users' => 'dashboard#users'
  # get 'dashboard/users/:id', to: 'dashboard#user'
  # get 'dashboard/myrakes' => 'dashboard#myrakes'
  # get 'dashboard/histories' => 'dashboard#histories'

  namespace :dashboard do
    resources :users, only: [:index, :show]
    resources :master_rakes, only: [:index, :show]
    resources :myrakes, only: [:index]
    resources :histories, only: [:index]
    resources :heap_leaflet_maps, only: [:index], as: "tasks"
  end

  resources :histories, only: [:create]

  resources :users, only: [:update, :show, :notification_read] do
    collection do
      get 'notification_read'
    end
  end

  resources :channels, except: [:edit, :update, :destroy] do
    member do
      get 'refresh_feed'
    end
    collection do
      get :autocomplete_channel_source
    end
  end

  resources :heaps, only: [:update] do
    member do
      get 'add_leaflet'
      get 'remove_leaflet'
    end
  end

  resources :leaflets, only: [:new, :create] do
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
      get 'create_rake'
      get 'get_url_title'
      get 'mark_day'
      get 'unmark_day'
      get 'add_channel'
      get 'remove_channel'
      get 'add_leaflet'
      get 'update_filter'
      get 'toggle_channel_display'
      get 'news'
      get 'saved'
      post 'toggle_top_rake'
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
