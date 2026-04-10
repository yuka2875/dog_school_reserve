class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.date :reserved_date
      t.string :reserved_time

      t.timestamps
    end
  end
end
