# == Schema Information
#
# Table name: bookings
#
#  id           :bigint           not null, primary key
#  flight_id    :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  confirmation :string           not null
#
require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:flight) }
    it { should have_many(:passenger_bookings) }
    it { should have_many(:passengers) }
  end
end
