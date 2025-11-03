FactoryBot.define do
  factory :system_talk_group do
    association :system
    association :talk_group
    timeslot { 1 }

    # Trait for timeslot 2
    trait :timeslot_2 do
      timeslot { 2 }
    end

    # Trait for nil timeslot (non-DMR systems)
    trait :no_timeslot do
      timeslot { nil }
    end
  end
end
