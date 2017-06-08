Rails.application.routes.draw do
  get 'dashboard/panel'
  get 'dashboard/editp'
  get 'dashboard/get_myskin', to: 'dashboard#get_myskin'
  post 'dashboard/get_myskin'
  get 'dashboard/update', to: 'dashboard#update'
  get 'dashboard/update_skin'
  post 'dashboard/update_image'
  post 'dashboard/update_password'
  post 'dashboard/update_skin'
  get 'dashboard/panel', :to => 'devise/registrations#new'
  get 'dashboard/newTransaction'
  get 'dashboard/historicalTransactions'
  get 'dashboard/shopping_student'
  get 'dashboard/auction_student'
  get 'dashboard/buyProduct'
  get 'dashboard/bidAuction'
  get 'dashboard/delete_product'
  get 'dashboard/delete_auction'
  get 'dashboard/getBudget'
  get 'dashboard/auction_student'
  # Only for professors
  get 'dashboard/studentsHandler'
  get 'dashboard/shopping_teacher'
  get 'dashboard/auction_teacher'
  get 'dashboard/newStudents', to: 'dashboard#newStudents'
  get 'dashboard/shopping_teacher_Handler', to: 'dashboard#shopping_teacher_Handler'
  get 'dashboard/auction_teacher_Handler', to: 'dashboard#auction_teacher_Handler'
  get 'dashboard/editStudents', to: 'dashboard#editStudents'
  get 'dashboard/editClasses', to: 'dashboard#editClasses'
  get 'dashboard/update_class', to: 'dashboard#update_class'
  get 'dashboard/addClasses', to: 'dashboard#addClasses'  
  post 'dashboard/import'
  get 'dashboard/community'
  get 'dashboard/student_historics'
  get 'dashboard/userTransactions', to: 'dashboard#userTransactions'
  get 'dashboard/transfer'
  get 'dashboard/newProduct'
  get 'dashboard/newAuction'
  get 'dashboard/createnewClass'

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
