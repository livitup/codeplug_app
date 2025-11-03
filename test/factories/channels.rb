FactoryBot.define do
  factory :channel do
    association :codeplug
    association :system
    name { Faker::Lorem.words(number: 2).join(" ").titleize }
    long_name { Faker::Lorem.words(number: 4).join(" ").titleize }
    short_name { Faker::Alphanumeric.alpha(number: 4).upcase }
    power_level { [ "High", "Medium", "Low" ].sample }
    bandwidth { [ "12.5kHz", "25kHz" ].sample }
    tone_mode { "none" }
    transmit_permission { "allow" }

    # Trait for digital channel with talkgroup
    trait :digital do
      after(:build) do |channel|
        dmr_system = create(:system, :dmr)
        talkgroup = create(:talk_group)
        system_talkgroup = create(:system_talk_group, system: dmr_system, talk_group: talkgroup, timeslot: 1)
        channel.system = dmr_system
        channel.system_talk_group = system_talkgroup
      end
    end

    # Trait for analog channel
    trait :analog do
      after(:build) do |channel|
        analog_system = create(:system, :analog)
        channel.system = analog_system
        channel.system_talk_group = nil
      end
    end

    # Trait for transmit forbidden
    trait :no_transmit do
      transmit_permission { "forbid_tx" }
    end
  end
end
