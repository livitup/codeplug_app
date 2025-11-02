FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    name { Faker::Name.name }
    callsign { "#{('A'..'Z').to_a.sample}#{rand(1..9)}#{('A'..'Z').to_a.sample(3).join}" }
    default_power_level { [ "High", "Medium", "Low" ].sample }
    measurement_preference { [ "metric", "imperial" ].sample }
  end
end
