FactoryBot.define do
  factory :codeplug_zone do
    association :codeplug
    association :zone
    sequence(:position) { |n| n }

    # Ensure zone belongs to the same codeplug
    after(:build) do |cz|
      cz.zone.codeplug = cz.codeplug if cz.codeplug && cz.zone
    end
  end
end
