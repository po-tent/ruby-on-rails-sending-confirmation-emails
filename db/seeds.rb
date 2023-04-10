# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

DURATIONS = {
  'SAN' => {
    'DTW' => 252,
    'JFK' => 304,
    'SFO' => 103,
    'ORD' => 254,
    'SLC' => 111,
    'DFW' => 182,
    'SEA' => 175,
    'BOS' => 308,
    'PIT' => 247
  },
  'DTW' => {
    'JFK' => 86,
    'SFO' => 284,
    'ORD' => 57,
    'SLC' => 195,
    'DFW' => 137,
    'SEA' => 245,
    'BOS' => 111,
    'PIT' => 53
  },
  'JFK' => {
    'SFO' => 320,
    'ORD' => 106,
    'SLC' => 251,
    'DFW' => 151,
    'SEA' => 301,
    'BOS' => 51,
    'PIT' => 68
  },
  'SFO' => {
    'ORD' => 238,
    'SLC' => 109,
    'DFW' => 194,
    'SEA' => 102,
    'BOS' => 334,
    'PIT' => 284
  },
  'ORD' => {
    'SLC' => 169,
    'DFW' => 116,
    'SEA' => 183,
    'BOS' => 121,
    'PIT' => 82
  },
  'SLC' => {
    'DFW' => 139,
    'SEA' => 104,
    'BOS' => 285,
    'PIT' => 206
  },
  'DFW' => {
    'SEA' => 207,
    'BOS' => 202,
    'PIT' => 147
  },
  'SEA' => {
    'BOS' => 310,
    'PIT' => 270
  },
  'BOS' => {
    'PIT' => 92
  },
  'PIT' => {}
}

def get_duration(origin, destination)
  DURATIONS[origin][destination] || DURATIONS[destination][origin]
end

def random_time
  Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
end

def random_passenger
  @passengers[@random_passengers.pop]
end

def random_passenger_reset!(n = @passengers.length)
  @random_passengers = (0...n).to_a.shuffle
end

ActiveRecord::Base.transaction do
  Booking.destroy_all
  Passenger.destroy_all
  Flight.destroy_all
  Airport.destroy_all

  ActiveRecord::Base.connection.reset_pk_sequence!('bookings')
  ActiveRecord::Base.connection.reset_pk_sequence!('passengers')
  ActiveRecord::Base.connection.reset_pk_sequence!('flights')
  ActiveRecord::Base.connection.reset_pk_sequence!('airports')

  airports = []
  airports[0] = Airport.create(code: 'PIT', name: 'Pittsburgh International Airport', city: 'Pittsburgh')
  airports[1] = Airport.create(code: 'SAN', name: 'San Diego International Airport', city: 'San Diego')
  airports[2] = Airport.create(code: 'DTW', name: 'Detroit Metropolitan Airport', city: 'Detroit')
  airports[3] = Airport.create(code: 'JFK', name: 'John F Kennedy International Airport', city: 'New York')
  airports[4] = Airport.create(code: 'SFO', name: 'San Francisco International Airport', city: 'San Francisco')
  airports[5] = Airport.create(code: 'ORD', name: 'O\'hare International Airport', city: 'Chicago')
  airports[6] = Airport.create(code: 'SLC', name: 'Salt Lake City International Airport', city: 'Salt Lake City')
  airports[7] = Airport.create(code: 'DFW', name: 'Dallas / Fort Worth International Airport', city: 'Dallas')
  airports[8] = Airport.create(code: 'SEA', name: 'Seattle-Tacoma International Airport', city: 'Seattle')
  airports[9] = Airport.create(code: 'BOS', name: 'Logan International Airport', city: 'Boston')

  Date.new(2021, 11, 1).upto(Date.new(2021, 11, 30)).each do |date|
    airports.each do |origin|
      airports.each do |destination|
        next if origin == destination

        3.times { Flight.create(date: date,
                                time: random_time,
                                origin: origin,
                                destination: destination,
                                duration: get_duration(origin.code, destination.code))
                  }
      end
    end
  end

  example = Passenger.create(name: 'Odin', email: 'odin@example.com')

  @passengers = []
  10.times do |i|
    @passengers[i] = Passenger.create(name: Faker::Name.name, email: Faker::Internet.email)
  end

  5.times do |i|
    random_passenger_reset!
    flight = Flight.limit(1).order("RANDOM()").first
    booking = Booking.new(flight: flight)
    booking.passengers << example
    n = case i
        when 0 then 1
        when 4 then 2
        else i
        end
    n.times { booking.passengers << random_passenger }
    booking.save
  end
end
