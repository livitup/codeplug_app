FactoryBot.define do
  factory :dmr_mode_detail do
    color_code { 1 }

    # Trait for color code 0
    trait :color_code_zero do
      color_code { 0 }
    end

    # Trait for color code 15
    trait :color_code_max do
      color_code { 15 }
    end

    # Trait for mid-range color code
    trait :color_code_mid do
      color_code { 7 }
    end
  end
end
