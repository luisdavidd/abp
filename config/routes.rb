Rails.application.routes.draw do
  get 'dashboard/panel'
  get 'dashboard/editp'
  get 'dashboard/editStudent'
  get 'dashboard/shopping_teacher'
  get 'dashboard/auction_teacher'
  get 'dashboard/get_myskin', to: 'dashboard#get_myskin'
  post 'dashboard/get_myskin'
  get 'dashboard/update', to: 'dashboard#update'
  get 'dashboard/update_skin'
  post 'dashboard/update_image'
  post 'dashboard/update_password'
  post 'dashboard/update_skin'
  get 'dashboard/panel', :to => 'devise/registrations#new'
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
