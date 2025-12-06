FactoryBot.define do
  factory :system_talk_group do
    timeslot { 1 }

    # By default, create a valid DMR setup with matching network
    transient do
      dmr_network { nil }
      skip_associations { false }
    end

    after(:build) do |stg, evaluator|
      # Skip if associations are being tested or explicitly set to nil
      next if evaluator.skip_associations

      # Only set up associations if not already provided
      if stg.system_id.nil? && stg.system.nil?
        # Create a DMR network if not provided
        network = evaluator.dmr_network || create(:network, network_type: "Digital-DMR")

        # Create system and associate with network
        stg.system = create(:system, mode: "dmr", color_code: 1).tap do |sys|
          sys.networks << network unless sys.networks.include?(network)
        end

        # Create talkgroup on the same network if not provided
        stg.talk_group ||= create(:talk_group, network: network)
      elsif stg.talk_group_id.nil? && stg.talk_group.nil? && stg.system&.mode == "dmr"
        # If system is set but talkgroup is not, create one on the system's first network
        network = stg.system.networks.first || create(:network, network_type: "Digital-DMR").tap do |n|
          stg.system.networks << n
        end
        stg.talk_group = create(:talk_group, network: network)
      end
    end

    # Trait for timeslot 2
    trait :timeslot_2 do
      timeslot { 2 }
    end

    # Trait for nil timeslot (non-DMR systems)
    trait :no_timeslot do
      timeslot { nil }
    end

    # Trait for P25 system
    trait :p25 do
      timeslot { nil }
      after(:build) do |stg, _evaluator|
        p25_network = create(:network, :p25_network)
        stg.system = create(:system, :p25)
        stg.talk_group = create(:talk_group, network: p25_network)
      end
    end

    # Trait for testing nil associations
    trait :without_system do
      skip_associations { true }
      system { nil }
    end

    trait :without_talk_group do
      skip_associations { true }
      talk_group { nil }
    end
  end
end
