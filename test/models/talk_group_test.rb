require "test_helper"

class TalkGroupTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save talk_group with valid attributes" do
    talk_group = build(:talk_group)
    assert talk_group.save, "Failed to save talk_group with valid attributes"
  end

  test "should not save talk_group without name" do
    talk_group = build(:talk_group, name: nil)
    assert_not talk_group.save, "Saved talk_group without name"
    assert_includes talk_group.errors[:name], "can't be blank"
  end

  test "should not save talk_group without talkgroup_number" do
    talk_group = build(:talk_group, talkgroup_number: nil)
    assert_not talk_group.save, "Saved talk_group without talkgroup_number"
    assert_includes talk_group.errors[:talkgroup_number], "can't be blank"
  end

  test "should not save talk_group without network" do
    talk_group = build(:talk_group, network: nil)
    assert_not talk_group.save, "Saved talk_group without network"
    assert_includes talk_group.errors[:network], "must exist"
  end

  # Uniqueness Tests
  test "should not save talk_group with duplicate talkgroup_number within same network" do
    network = create(:network)
    create(:talk_group, network: network, talkgroup_number: "3181")
    duplicate_talk_group = build(:talk_group, network: network, talkgroup_number: "3181")
    assert_not duplicate_talk_group.save, "Saved talk_group with duplicate talkgroup_number in same network"
    assert_includes duplicate_talk_group.errors[:talkgroup_number], "has already been taken"
  end

  test "should save talk_group with same talkgroup_number in different network" do
    network1 = create(:network, name: "Network 1")
    network2 = create(:network, name: "Network 2")
    create(:talk_group, network: network1, talkgroup_number: "3181")
    talk_group2 = build(:talk_group, network: network2, talkgroup_number: "3181")
    assert talk_group2.save, "Failed to save talk_group with same talkgroup_number in different network"
  end

  # Association Tests
  test "should belong to network" do
    talk_group = build(:talk_group)
    assert_respond_to talk_group, :network
  end

  test "network association should be configured" do
    association = TalkGroup.reflect_on_association(:network)
    assert_not_nil association, "network association should exist"
    assert_equal :belongs_to, association.macro
  end

  # Attribute Tests
  test "should save talk_group with description" do
    talk_group = build(:talk_group, description: "Virginia statewide talkgroup")
    assert talk_group.save, "Failed to save talk_group with description"
  end

  test "should allow nil description" do
    talk_group = build(:talk_group, description: nil)
    assert talk_group.save, "Failed to save talk_group with nil description"
  end

  # Talkgroup Number Format Tests
  test "should save talk_group with numeric talkgroup_number" do
    talk_group = build(:talk_group, talkgroup_number: "3181")
    assert talk_group.save, "Failed to save talk_group with numeric talkgroup_number"
  end

  test "should save talk_group with talkgroup_number with leading zeros" do
    talk_group = build(:talk_group, talkgroup_number: "091")
    assert talk_group.save, "Failed to save talk_group with leading zeros in talkgroup_number"
    assert_equal "091", talk_group.talkgroup_number, "Leading zeros should be preserved"
  end

  test "should save talk_group with alphanumeric talkgroup_number" do
    talk_group = build(:talk_group, talkgroup_number: "TAC1")
    assert talk_group.save, "Failed to save talk_group with alphanumeric talkgroup_number"
  end
end
