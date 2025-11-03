FactoryBot.define do
  factory :system_network do
    association :system
    association :network
  end
end
