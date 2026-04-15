class Customer < ApplicationRecord
  has_many :reservations, dependent: :restrict_with_error
end
