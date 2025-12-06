require "test_helper"

class SystemTalkGroupTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save system_talk_group with valid attributes" do
    system_talk_group = build(:system_talk_group)
    assert system_talk_group.save, "Failed to save system_talk_group with valid attributes"
  end

  test "should not save system_talk_group without system" do
    system_talk_group = build(:system_talk_group, :without_system)
    assert_not system_talk_group.save, "Saved system_talk_group without system"
    assert_includes system_talk_group.errors[:system], "must exist"
  end

  test "should not save system_talk_group without talk_group" do
    system_talk_group = build(:system_talk_group, :without_talk_group)
    assert_not system_talk_group.save, "Saved system_talk_group without talk_group"
    assert_includes system_talk_group.errors[:talk_group], "must exist"
  end

  # Mode Validation Tests - Analog systems cannot have talkgroups
  test "should not save system_talk_group for analog system" do
    analog_system = create(:system, :analog)
    system_talk_group = build(:system_talk_group, system: analog_system)
    assert_not system_talk_group.save, "Saved system_talk_group for analog system"
    assert_includes system_talk_group.errors[:base], "Analog systems cannot be associated with talkgroups"
  end

  # Network Matching Tests - P25 systems require P25 talkgroups
  test "should save system_talk_group for P25 system with P25 network talkgroup" do
    p25_network = create(:network, :p25_network)
    p25_talkgroup = create(:talk_group, network: p25_network)
    p25_system = create(:system, :p25)

    system_talk_group = build(:system_talk_group, system: p25_system, talk_group: p25_talkgroup)
    assert system_talk_group.save, "Failed to save system_talk_group for P25 system with P25 talkgroup"
  end

  test "should not save system_talk_group for P25 system with DMR network talkgroup" do
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_talkgroup = create(:talk_group, network: dmr_network)
    p25_system = create(:system, :p25)

    system_talk_group = build(:system_talk_group, system: p25_system, talk_group: dmr_talkgroup)
    assert_not system_talk_group.save, "Saved system_talk_group for P25 system with DMR talkgroup"
    assert_includes system_talk_group.errors[:base], "P25 systems can only use talkgroups from P25 networks"
  end

  # Network Matching Tests - DMR systems require talkgroups from associated networks
  test "should save system_talk_group for DMR system with talkgroup from associated network" do
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_talkgroup = create(:talk_group, network: dmr_network)
    dmr_system = create(:system, mode: "dmr", color_code: 1)
    dmr_system.networks << dmr_network

    system_talk_group = build(:system_talk_group, system: dmr_system, talk_group: dmr_talkgroup, timeslot: 1)
    assert system_talk_group.save, "Failed to save system_talk_group for DMR system with associated network talkgroup"
  end

  test "should not save system_talk_group for DMR system with talkgroup from non-associated network" do
    associated_network = create(:network, network_type: "Digital-DMR", name: "Associated Network")
    other_network = create(:network, network_type: "Digital-DMR", name: "Other Network")
    other_talkgroup = create(:talk_group, network: other_network)
    dmr_system = create(:system, mode: "dmr", color_code: 1)
    dmr_system.networks << associated_network

    system_talk_group = build(:system_talk_group, system: dmr_system, talk_group: other_talkgroup, timeslot: 1)
    assert_not system_talk_group.save, "Saved system_talk_group for DMR system with non-associated network talkgroup"
    assert_includes system_talk_group.errors[:base], "DMR systems can only use talkgroups from their associated networks"
  end

  test "should not save system_talk_group for DMR system with no network associations" do
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_talkgroup = create(:talk_group, network: dmr_network)
    dmr_system = create(:system, mode: "dmr", color_code: 1)
    # Don't associate the system with any network

    system_talk_group = build(:system_talk_group, system: dmr_system, talk_group: dmr_talkgroup, timeslot: 1)
    assert_not system_talk_group.save, "Saved system_talk_group for DMR system with no network associations"
    assert_includes system_talk_group.errors[:base], "DMR systems can only use talkgroups from their associated networks"
  end

  # NXDN systems - should allow any talkgroup (for now, may refine later)
  test "should save system_talk_group for NXDN system" do
    network = create(:network, network_type: "Digital-DMR")
    talkgroup = create(:talk_group, network: network)
    nxdn_system = create(:system, :nxdn)

    system_talk_group = build(:system_talk_group, system: nxdn_system, talk_group: talkgroup)
    assert system_talk_group.save, "Failed to save system_talk_group for NXDN system"
  end

  # Timeslot Validation Tests
  test "should save system_talk_group with nil timeslot for P25 system" do
    p25_network = create(:network, :p25_network)
    p25_talkgroup = create(:talk_group, network: p25_network)
    p25_system = create(:system, :p25)

    system_talk_group = build(:system_talk_group, system: p25_system, talk_group: p25_talkgroup, timeslot: nil)
    assert system_talk_group.save, "Failed to save system_talk_group with nil timeslot for P25"
  end

  test "should not save system_talk_group with nil timeslot for DMR system" do
    dmr_system = create(:system, mode: "dmr")
    system_talk_group = build(:system_talk_group, system: dmr_system, timeslot: nil)
    assert_not system_talk_group.save, "Saved system_talk_group with nil timeslot for DMR system"
    assert_includes system_talk_group.errors[:timeslot], "is required for DMR systems"
  end

  test "should save system_talk_group with timeslot 1" do
    system_talk_group = build(:system_talk_group, timeslot: 1)
    assert system_talk_group.save, "Failed to save system_talk_group with timeslot 1"
  end

  test "should save system_talk_group with timeslot 2" do
    system_talk_group = build(:system_talk_group, timeslot: 2)
    assert system_talk_group.save, "Failed to save system_talk_group with timeslot 2"
  end

  test "should not save system_talk_group with timeslot 0" do
    system_talk_group = build(:system_talk_group, timeslot: 0)
    assert_not system_talk_group.save, "Saved system_talk_group with timeslot 0"
    assert_includes system_talk_group.errors[:timeslot], "must be 1 or 2"
  end

  test "should not save system_talk_group with timeslot 3" do
    system_talk_group = build(:system_talk_group, timeslot: 3)
    assert_not system_talk_group.save, "Saved system_talk_group with timeslot 3"
    assert_includes system_talk_group.errors[:timeslot], "must be 1 or 2"
  end

  # Uniqueness Tests
  test "should not save system_talk_group with duplicate system, talk_group, and timeslot" do
    # Create DMR system with network association
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_talkgroup = create(:talk_group, network: dmr_network)
    dmr_system = create(:system, mode: "dmr", color_code: 1)
    dmr_system.networks << dmr_network

    create(:system_talk_group, system: dmr_system, talk_group: dmr_talkgroup, timeslot: 1)

    duplicate = build(:system_talk_group, system: dmr_system, talk_group: dmr_talkgroup, timeslot: 1)
    assert_not duplicate.save, "Saved system_talk_group with duplicate system/talk_group/timeslot"
    assert_includes duplicate.errors[:system_id], "has already been taken"
  end

  test "should save system_talk_group with same system and talk_group but different timeslot" do
    # Create DMR system with network association
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_talkgroup = create(:talk_group, network: dmr_network)
    dmr_system = create(:system, mode: "dmr", color_code: 1)
    dmr_system.networks << dmr_network

    create(:system_talk_group, system: dmr_system, talk_group: dmr_talkgroup, timeslot: 1)

    stg2 = build(:system_talk_group, system: dmr_system, talk_group: dmr_talkgroup, timeslot: 2)
    assert stg2.save, "Failed to save system_talk_group with different timeslot"
  end

  test "should save system_talk_group with same system and talk_group but one nil timeslot" do
    # Use P25 system since analog systems cannot have talkgroups
    p25_network = create(:network, :p25_network)
    p25_talkgroup = create(:talk_group, network: p25_network)
    p25_system = create(:system, :p25)

    create(:system_talk_group, system: p25_system, talk_group: p25_talkgroup, timeslot: 1)

    stg2 = build(:system_talk_group, system: p25_system, talk_group: p25_talkgroup, timeslot: nil)
    assert stg2.save, "Failed to save system_talk_group with nil timeslot"
  end

  test "should not save system_talk_group with duplicate system, talk_group, and nil timeslot" do
    # Use P25 system since analog systems cannot have talkgroups
    p25_network = create(:network, :p25_network)
    p25_talkgroup = create(:talk_group, network: p25_network)
    p25_system = create(:system, :p25)

    create(:system_talk_group, system: p25_system, talk_group: p25_talkgroup, timeslot: nil)

    duplicate = build(:system_talk_group, system: p25_system, talk_group: p25_talkgroup, timeslot: nil)
    assert_not duplicate.save, "Saved system_talk_group with duplicate system/talk_group/nil timeslot"
  end

  # Association Tests
  test "should belong to system" do
    system_talk_group = build(:system_talk_group)
    assert_respond_to system_talk_group, :system
  end

  test "should belong to talk_group" do
    system_talk_group = build(:system_talk_group)
    assert_respond_to system_talk_group, :talk_group
  end

  test "system association should be configured" do
    association = SystemTalkGroup.reflect_on_association(:system)
    assert_not_nil association, "system association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "talk_group association should be configured" do
    association = SystemTalkGroup.reflect_on_association(:talk_group)
    assert_not_nil association, "talk_group association should exist"
    assert_equal :belongs_to, association.macro
  end
end
