Rails.application.routes.draw do
  devise_for :users
  resources :keyword_mappings
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/tomcat/webhook', to: 'tomcat#webhook'

  root to: 'home#index'
end
