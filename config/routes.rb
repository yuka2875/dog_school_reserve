Rails.application.routes.draw do
  root "reservations#customer_info"

  get "reservations/customer_info"
  post "reservations/customer_info"
  get "reservations/index"
  get "reservations/complete"
  post "reservations/complete"

  get "admin/reservations", to: "reservations#admin"
  get "admin/customers", to: "reservations#customers"
  delete "admin/customers/:id", to: "reservations#destroy_customer", as: :destroy_customer
  get "admin/customers/:id/edit", to: "reservations#edit_customer", as: :edit_customer
  patch "admin/customers/:id", to: "reservations#update_customer", as: :update_customer
  get "admin/customers/new", to: "reservations#new_customer", as: :new_customer
  post "admin/customers", to: "reservations#create_customer", as: :create_customer
end
