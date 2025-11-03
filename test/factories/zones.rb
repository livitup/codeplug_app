FactoryBot.define do
  factory :zone do
    association :codeplug
    name { Faker::Lorem.words(number: 2).join(" ").titleize }
    long_name { Faker::Lorem.words(number: 4).join(" ").titleize }
    short_name { Faker::Alphanumeric.alpha(number: 3).upcase }
  end
end
