require 'resque/server'

Rails.application.routes.draw do

  namespace :admin do
    get 'advisors/index'
  end

  namespace :admin do
    get 'advisor/index'
  end

  # ----------------------------------------------------------------------------
  # General access

  root :to => "home#index"

  # Global pages

  # Index:
  get 'home/index'
  post '/' => 'home#index'
  post '/mailing_list_signup' => 'home#mailing_list_signup'

  # Sign up:
  get 'warehouses/addresses' => 'home#warehouses'
  post 'signup/create' => 'signup#create'
  post 'signup/address' => 'signup#address'
  post 'signup/mailing_list_signup' => 'signup#mailing_list_signup'

  #T&C
  get '/tc' => 'home#terms'
  get '/gate' => 'home#gate'

  # Hooks:
  post 'hooks/updateorder'

  #New Home Page
  get '/aidani' => 'home#aidani'


  # ------------

  resources :promotions, :share, :help, :jobs
  resources :delivery do
    collection do
      get 'get_courier_location'
    end
  end

  resources :orders do
    get 'status'
    get 'substitution_request'
    post 'substitute'
    get 'cancellation_request'
    post 'cancel'
    get 'accept'
  end

  # ----------------------------------------------------------------------------
  # User authentication:

  devise_for :users, :controllers => {sessions: 'sessions'}

  devise_scope :user do
    get "/signup" => "devise/registrations#new"
    get "/login" => "devise/sessions#new"
    delete "/logout" => "devise/sessions#destroy"
  end

  scope '/signup' do
    get 'entercode' => 'home#code'
    post 'activate' => 'home#activate'
  end

  # ----------------------------------------------------------------------------
  # Customer access

  # Actions for customers are under "/shop"
  # resources :shop
  scope '/shop' do
    get 'welcome' => 'shop#welcome'
    get 'mywines' => 'shop#list'
    # get 'list' => 'shop#list'
    get 'show' => 'shop#show'
    get 'neworder' => 'shop#new'
    get 'confirmed' => 'shop#confirmed'
    get 'edit' => 'shop#edit'
    post 'create' => 'shop#create'
    get 'update' => 'shop#update'
    get 'destroy' => 'shop#destroy'

  end


  # ----------------------------------------------------------------------------
  # Admin access

  # Actions for admins are under "/admin"
  namespace 'admin' do
    root :to => 'orders#index'
    resources :types
    resources :bottlings
    resources :inventories,
              :producers,
              :regions,
              :vinifications,
              :appellations,
              :grapes,
              :maturations,
              :locales,
              :subregions,
              :wines,
              :compositions do
      collection do
        post 'import'
        get 'upload'
      end
    end
    resources :allergies
    resources :foods
    resources :occasions
    resources :categories
    resources :roles
    resources :users
    resources :addresses
    resources :warehouses do
      post :remove_user
      get :shutl
    end
    resources :orders do
      post 'cancel'
      post 'charge'
      post 'send_receipt'
      post 'finished_advice'
      post 'schedule_google_coordinate'
      collection do
        post 'packing_complete'
        get 'refresh_all'
        get 'order_counts'
        post 'increment_notification_count'
      end
    end
    resources :payments
    resources :statuses
    resources :delivery
    resources :devices do
      collection do
        post 'register'
      end
    end
    resources :oauth do
      collection do
        get 'callback'
      end
    end
    post '/orders/list' => 'orders#list'
    get 'advise/choose' => 'advisors#choose'
    get 'advise/item/:id' => 'advisors#item'
    post 'advise/item/:id' => 'advisors#update'
    post 'advise/choose' => 'advisors#choose'
    post 'advise/complete' => 'advisors#complete'
    post 'advise/results' => 'advisors#results'

  end

  mount Resque::Server.new, at: '/resque'

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
