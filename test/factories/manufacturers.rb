FactoryBot.define do
  factory :manufacturer do
    name { Faker::Company.name }
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
