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
FactoryBot.define do
  factory :flight do
    date { "2020-10-28" }
    time {  "23:05:49" }
    duration { 100 }
    origin { create(:airport) }
    destination { create(:airport) }
  end
end
