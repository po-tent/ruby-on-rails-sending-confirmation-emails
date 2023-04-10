class SeparateDateAndTimeInFlightsTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :flights, :takeoff, :datetime, null: false

    add_column :flights, :date, :date, null: false
    add_column :flights, :time, :time, null: false
  end
end
