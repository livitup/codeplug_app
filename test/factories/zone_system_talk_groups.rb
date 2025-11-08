FactoryBot.define do
  factory :zone_system_talk_group do
    zone_system
    system_talk_group { zone_system ? association(:system_talk_group, system: zone_system.system) : association(:system_talk_group) }
  end
end
