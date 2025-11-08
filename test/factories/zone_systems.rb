FactoryBot.define do
  factory :zone_system do
    association :zone
    association :system
    sequence(:position) { |n| n }
  end
end
