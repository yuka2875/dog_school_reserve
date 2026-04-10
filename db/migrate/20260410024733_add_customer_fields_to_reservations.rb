class AddCustomerFieldsToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :owner_name, :string
    add_column :reservations, :phone_number, :string
    add_column :reservations, :dog_name, :string
    add_column :reservations, :dog_age, :string
    add_column :reservations, :dog_gender, :string
    add_column :reservations, :dog_breed, :string
    add_column :reservations, :service_type, :integer
    add_column :reservations, :referral_source, :string
  end
end
