Rails.application.routes.draw do
  root "reservations#index"
  get "reservations/index"
  get "reservations/confirm"
  get "reservations/complete"
  get "admin/reservations", to: "reservations#admin"
end
