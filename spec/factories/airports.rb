# == Schema Information
#
# Table name: airports
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  name       :string           not null
#  city       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :airport do
    code { Faker::Alphanumeric.alpha(number: 10).upcase }
    name { "MyString" }
    city { "MyString" }
  end
end
