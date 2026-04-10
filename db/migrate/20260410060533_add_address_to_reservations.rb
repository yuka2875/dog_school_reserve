class AddAddressToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :address, :string
    add_column :reservations, :pickup_required, :boolean
  end
end
