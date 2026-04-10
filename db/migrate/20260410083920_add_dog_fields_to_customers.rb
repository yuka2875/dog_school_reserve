class AddDogFieldsToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :dog_name, :string
    add_column :customers, :dog_breed, :string
    add_column :customers, :dog_age, :string
    add_column :customers, :dog_gender, :string
  end
end
