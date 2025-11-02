FactoryBot.define do
  factory :codeplug_layout do
    association :radio_model
    name { "CHIRP CSV Format" }
    layout_definition do
      {
        "columns" => [
          { "header" => "Channel Name", "maps_to" => "long_name" },
          { "header" => "RX Freq", "maps_to" => "system.rx_frequency" },
          { "header" => "TX Freq", "maps_to" => "system.tx_frequency" },
          { "header" => "Power", "maps_to" => "power_level" }
        ]
      }
    end

    # Optional user association - defaults to nil (system layout)
    user { nil }

    # Trait for user-created custom layout
    trait :custom do
      association :user
      name { "Custom Layout" }
    end

    # Trait for system default layout
    trait :system_default do
      user { nil }
      name { "System Default" }
    end
  end
end
