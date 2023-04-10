# == Schema Information
#
# Table name: passengers
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Passenger, type: :model do
  describe 'associations' do
    it { should have_many(:passenger_bookings) }
    it { should have_many(:bookings) }
    it { should have_many(:flights) }
  end
end
