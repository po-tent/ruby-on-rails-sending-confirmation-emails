# == Schema Information
#
# Table name: flights
#
#  id             :bigint           not null, primary key
#  duration       :integer          not null
#  origin_id      :bigint           not null
#  destination_id :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  date           :date             not null
#  time           :time             not null
#  flight_number  :integer          default(-1), not null
#
require 'rails_helper'

RSpec.describe Flight, type: :model do
  describe 'associations' do
    it { should belong_to(:origin) }
    it { should belong_to(:destination) }
    it { should have_many(:bookings) }
    it { should have_many(:passengers) }
  end
end
