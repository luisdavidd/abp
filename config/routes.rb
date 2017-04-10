Rails.application.routes.draw do
  get 'dashboard/panel'
  get 'dashboard/editp'
  devise_for :users
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  as :user do
  	get 'dashboard/panel', :to => 'devise/registrations#edit', :as => :user_root
  end
 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"
end
