FactoryBot.define do
  factory :codeplug_zone do
    association :codeplug
    association :zone
    sequence(:position) { |n| n }
  end
end
