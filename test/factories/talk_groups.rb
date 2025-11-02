FactoryBot.define do
  factory :talk_group do
    association :network
    sequence(:name) { |n| "TalkGroup #{n}" }
    sequence(:talkgroup_number) { |n| (3100 + n).to_s }
    description { "A digital radio talkgroup" }

    # Trait for Virginia
    trait :virginia do
      name { "Virginia" }
      talkgroup_number { "3151" }
      description { "Virginia statewide talkgroup" }
    end

    # Trait for Worldwide
    trait :worldwide do
      name { "Worldwide" }
      talkgroup_number { "91" }
      description { "Worldwide calling channel" }
    end

    # Trait for TAC channels
    trait :tac do
      name { "TAC 1" }
      talkgroup_number { "8951" }
      description { "Tactical channel 1" }
    end

    # Trait with leading zeros
    trait :leading_zeros do
      name { "Test Group" }
      talkgroup_number { "091" }
      description { "Talkgroup with leading zeros" }
    end

    # Trait for minimal talkgroup
    trait :minimal do
      description { nil }
    end
  end
end
