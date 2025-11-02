FactoryBot.define do
  factory :p25_mode_detail do
    nac { "293" }

    # Trait for different NAC values
    trait :nac_001 do
      nac { "001" }
    end

    trait :nac_f7e do
      nac { "F7E" }
    end

    trait :nac_123 do
      nac { "123" }
    end
  end
end
