class AddFlightNumberToFlights < ActiveRecord::Migration[6.0]
  def change
    add_column :flights, :flight_number, :integer, null: false, default: -1

    Flight.all.each do |flight|
      flight.reset_flight_number!
    end
  end
end
