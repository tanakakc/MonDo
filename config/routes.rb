Apps30::Application.routes.draw do
  root 'users#new'
  post '/', to: 'users#create'
  get '/detail', to: 'users#detail'
  get '/users/password/:id/:hash_token', to: 'users#password', as: 'password'
  post '/password/create', to: 'users#password_create'
  get '/edit', to: 'users#edit'
  patch '/edit/update', to: 'users#update'
  get '/privacy_policy', to: 'users#privacy_policy'
  patch '/select_mail', to: 'users#select_mail'
  delete '/account_delete', to: 'users#destroy'

  post '/login', to: 'sessions#create'
  get '/login', to: 'sessions#new'
  delete '/logout', to: 'sessions#destroy'
  
  get '/days/index', to: 'days#index'
  get '/days/:id/new', to: 'days#new', constraints: {:id => /[0-9]+/}
  post '/days', to: 'days#create'
  get  '/days/:id', to: 'days#show', constraints: {:id => /[0-9]+/}
  delete '/days/reset', to: 'days#destroy'
    
  get  '/password_resets/new', to: 'password_resets#new'
  post '/password_resets', to: 'password_resets#create'
  get  '/password_resets/:hash_token/edit', to: 'password_resets#edit'
  patch '/password_resets/:hash_token', to: 'password_resets#update'

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
