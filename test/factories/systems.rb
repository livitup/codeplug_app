FactoryBot.define do
  factory :system do
    sequence(:name) { |n| "System #{n}" }
    mode { "dmr" }
    tx_frequency { 145.230 }
    rx_frequency { 144.630 }
    bandwidth { "25kHz" }
    supports_tx_tone { false }
    supports_rx_tone { false }
    tx_tone_value { nil }
    rx_tone_value { nil }
    city { "Richmond" }
    state { "Virginia" }
    county { "Henrico" }
    latitude { 37.5407 }
    longitude { -77.4360 }

    # Default to DMR mode detail
    association :mode_detail, factory: :dmr_mode_detail

    # Trait for analog repeater
    trait :analog do
      mode { "analog" }
      association :mode_detail, factory: :analog_mode_detail
      supports_tx_tone { true }
      tx_tone_value { "127.3" }
    end

    # Trait for P25 system
    trait :p25 do
      mode { "p25" }
      association :mode_detail, factory: :p25_mode_detail
    end

    # Trait for NXDN system
    trait :nxdn do
      mode { "nxdn" }
      association :mode_detail, factory: :analog_mode_detail
    end

    # Trait for simplex
    trait :simplex do
      name { "Simplex 146.52" }
      tx_frequency { 146.52 }
      rx_frequency { 146.52 }
    end

    # Trait with CTCSS tones
    trait :with_ctcss do
      supports_tx_tone { true }
      supports_rx_tone { true }
      tx_tone_value { "127.3" }
      rx_tone_value { "127.3" }
    end

    # Trait with DCS tones
    trait :with_dcs do
      supports_tx_tone { true }
      tx_tone_value { "065" }
    end

    # Trait without location
    trait :no_location do
      city { nil }
      state { nil }
      county { nil }
      latitude { nil }
      longitude { nil }
    end
  end
end
