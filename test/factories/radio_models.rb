FactoryBot.define do
  factory :radio_model do
    association :manufacturer
    name { Faker::Device.model_name }
    supported_modes { [ "analog", "dmr" ].sample(rand(1..2)) }
    max_zones { rand(1..100) }
    max_channels_per_zone { [ 16, 32, 64, 128, 256 ].sample }
    long_channel_name_length { 16 }
    short_channel_name_length { 8 }
    long_zone_name_length { 16 }
    short_zone_name_length { 8 }
    frequency_ranges do
      [
        { band: "2m", min: 144.0, max: 148.0 },
        { band: "70cm", min: 420.0, max: 450.0 }
      ]
    end
    system_record { false }
    user { nil }

    trait :system do
      system_record { true }
      user { nil }
    end

    trait :user_owned do
      system_record { false }
      association :user
    end
  end
end
