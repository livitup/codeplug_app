FactoryBot.define do
  factory :network do
    sequence(:name) { |n| "Network #{n}" }
    description { "A digital radio network" }
    website { "https://example.com" }
    network_type { "Digital-DMR" }

    # Trait for Brandmeister
    trait :brandmeister do
      name { "Brandmeister" }
      description { "Global DMR network" }
      website { "https://brandmeister.network" }
      network_type { "Digital-DMR" }
    end

    # Trait for DMRVA
    trait :dmrva do
      name { "DMRVA" }
      description { "DMR network in Virginia" }
      website { "https://dmrva.net" }
      network_type { "Digital-DMR" }
    end

    # Trait for P25
    trait :p25_network do
      name { "P25 Network" }
      description { "Project 25 digital network" }
      network_type { "Digital-P25" }
    end

    # Trait for analog
    trait :analog_network do
      name { "Analog Repeater Network" }
      description { "Analog FM repeater network" }
      network_type { "Analog" }
    end

    # Trait for minimal network (network_type is now required)
    trait :minimal do
      name { "Minimal Network" }
      description { nil }
      website { nil }
      network_type { "Analog" }
    end
  end
end
