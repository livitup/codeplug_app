FactoryBot.define do
  factory :channel_zone do
    association :channel
    association :zone
    sequence(:position) { |n| n }
  end
end
