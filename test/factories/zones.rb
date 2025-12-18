FactoryBot.define do
  factory :zone do
    association :user
    name { Faker::Lorem.words(number: 2).join(" ").titleize }
    long_name { Faker::Lorem.words(number: 4).join(" ").titleize }
    short_name { Faker::Alphanumeric.alpha(number: 3).upcase }
    public { false }
  end
end
