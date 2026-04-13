Rails.application.routes.draw do
  root "reservations#customer_info"

  get "reservations/customer_info"
  post "reservations/customer_info"
  get "reservations/index"
  get "reservations/complete"
  post "reservations/complete"
  post "reservations/confirm"
  get "reservations/confirm"

  get "admin/reservations", to: "reservations#admin"
  get "admin/customers", to: "reservations#customers"
  delete "admin/customers/:id", to: "reservations#destroy_customer", as: :destroy_customer
  get "admin/customers/:id/edit", to: "reservations#edit_customer", as: :edit_customer
  patch "admin/customers/:id", to: "reservations#update_customer", as: :update_customer
  get "admin/customers/new", to: "reservations#new_customer", as: :new_customer
  post "admin/customers", to: "reservations#create_customer", as: :create_customer
  get  "admin/reservations/new", to: "reservations#new", as: :new_admin_reservation
  post "admin/reservations",     to: "reservations#create"
  get "admin/reservations/list", to: "reservations#list", as: :admin_reservations_list
  post "admin/reservations/review", to: "reservations#review", as: :review_admin_reservations
  get  "admin/sns", to: "admin/sns_posts#index", as: :admin_sns
  post "admin/sns/generate", to: "admin/sns_posts#generate", as: :admin_sns_generate
end
