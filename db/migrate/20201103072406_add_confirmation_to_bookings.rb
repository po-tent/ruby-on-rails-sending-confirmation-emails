class AddConfirmationToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :confirmation, :string, null: false
    add_index :bookings, :confirmation, unique: true
  end
end
