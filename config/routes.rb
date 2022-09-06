Rails.application.routes.draw do
  namespace :api do 
    namespace :v1 do 
      mount_devise_token_auth_for 'Admin', at: 'auth'
      resources :images, only: [:index, :create]
    end
  end
end
