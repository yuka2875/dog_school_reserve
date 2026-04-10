class Reservation < ApplicationRecord
  enum :service_type, {
    kindergarten: 0,
    nursery: 1,
    hotel: 2,
    temporary_care: 3
  }
end
