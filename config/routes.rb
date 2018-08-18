Rails.application.routes.draw do
  devise_for :users
  root 'welcome#index'  
  post '/tomcat/webhook', to: 'tomcat#webhook'
  resources :keyword_mappings
  resources :push_messages, only: [:new, :create]
end
