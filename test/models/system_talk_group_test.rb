require "test_helper"

class SystemTalkGroupTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save system_talk_group with valid attributes" do
    system_talk_group = build(:system_talk_group)
    assert system_talk_group.save, "Failed to save system_talk_group with valid attributes"
  end

  test "should not save system_talk_group without system" do
    system_talk_group = build(:system_talk_group, system: nil)
    assert_not system_talk_group.save, "Saved system_talk_group without system"
    assert_includes system_talk_group.errors[:system], "must exist"
  end

  test "should not save system_talk_group without talk_group" do
    system_talk_group = build(:system_talk_group, talk_group: nil)
    assert_not system_talk_group.save, "Saved system_talk_group without talk_group"
    assert_includes system_talk_group.errors[:talk_group], "must exist"
  end

  # Timeslot Validation Tests
  test "should save system_talk_group with nil timeslot for non-DMR system" do
    analog_system = create(:system, :analog)
    system_talk_group = build(:system_talk_group, system: analog_system, timeslot: nil)
    assert system_talk_group.save, "Failed to save system_talk_group with nil timeslot for non-DMR"
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
    system = create(:system)
    talk_group = create(:talk_group)
    create(:system_talk_group, system: system, talk_group: talk_group, timeslot: 1)

    duplicate = build(:system_talk_group, system: system, talk_group: talk_group, timeslot: 1)
    assert_not duplicate.save, "Saved system_talk_group with duplicate system/talk_group/timeslot"
    assert_includes duplicate.errors[:system_id], "has already been taken"
  end

  test "should save system_talk_group with same system and talk_group but different timeslot" do
    system = create(:system)
    talk_group = create(:talk_group)
    create(:system_talk_group, system: system, talk_group: talk_group, timeslot: 1)

    stg2 = build(:system_talk_group, system: system, talk_group: talk_group, timeslot: 2)
    assert stg2.save, "Failed to save system_talk_group with different timeslot"
  end

  test "should save system_talk_group with same system and talk_group but one nil timeslot" do
    analog_system = create(:system, :analog)
    talk_group = create(:talk_group)
    create(:system_talk_group, system: analog_system, talk_group: talk_group, timeslot: 1)

    stg2 = build(:system_talk_group, system: analog_system, talk_group: talk_group, timeslot: nil)
    assert stg2.save, "Failed to save system_talk_group with nil timeslot"
  end

  test "should not save system_talk_group with duplicate system, talk_group, and nil timeslot" do
    analog_system = create(:system, :analog)
    talk_group = create(:talk_group)
    create(:system_talk_group, system: analog_system, talk_group: talk_group, timeslot: nil)

    duplicate = build(:system_talk_group, system: analog_system, talk_group: talk_group, timeslot: nil)
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
