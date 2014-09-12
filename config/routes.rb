Rails.application.routes.draw do

  # get 'buy/new'

  # get 'buy/create'

  resources :payments

  root :to => "home#index"

  # Global pages

  # Index:
  get 'home/index'

  # Sign up:
  get 'warehouses/addresses' => 'home#warehouses'

  # Signed only:
  get 'welcome' => 'home#welcome'

  # Orders:
  get 'orders/list' => 'orders#list'
  get 'orders/confirmed' => 'orders#confirmed'

  # ------------

  resources :orders

  devise_for :users

  # Actions for customers are under "/shop"
  scope '/shop' do
    resources :buy
  end

  # Actions for admins are under "/admin"
  scope "/admin" do
    resources :producers
    resources :regions
    resources :subregions
    resources :grapes
    resources :types
    resources :bottlings
    resources :maturations
    resources :allergies
    resources :notes
    resources :foods
    resources :occasions
    resources :appellations
    resources :wines
    resources :roles
    resources :users
    resources :addresses
    resources :warehouses
    resources :orders
  end

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
