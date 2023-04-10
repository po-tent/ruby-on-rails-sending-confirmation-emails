# == Schema Information
#
# Table name: passenger_bookings
#
#  passenger_id :bigint           not null
#  booking_id   :bigint           not null
#
require 'rails_helper'

RSpec.describe PassengerBooking, type: :model do
  describe 'associations' do
    it { should belong_to(:passenger) }
    it { should belong_to(:booking) }
  end
end
