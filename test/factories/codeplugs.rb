FactoryBot.define do
  factory :codeplug do
    association :user
    name { Faker::Lorem.words(number: 3).join(" ").titleize }
    description { Faker::Lorem.sentence }
    public { false }

    # Trait for public codeplug
    trait :public do
      public { true }
    end
  end
end
