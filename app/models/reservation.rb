class Reservation < ApplicationRecord
  belongs_to :customer
  enum :service_type, {
    kindergarten: 0,
    nursery: 1,
    hotel: 2,
    temporary_care: 3
  }
end
