require "test_helper"

class ZoneSystemTalkGroupTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save zone_system_talk_group with valid attributes" do
    zone_system_talk_group = build(:zone_system_talk_group)
    assert zone_system_talk_group.save, "Failed to save zone_system_talk_group with valid attributes"
  end

  test "should not save zone_system_talk_group without zone_system" do
    zone_system_talk_group = build(:zone_system_talk_group, zone_system: nil)
    assert_not zone_system_talk_group.save, "Saved zone_system_talk_group without zone_system"
    assert_includes zone_system_talk_group.errors[:zone_system], "must exist"
  end

  test "should not save zone_system_talk_group without system_talk_group" do
    zone_system_talk_group = build(:zone_system_talk_group, system_talk_group: nil)
    assert_not zone_system_talk_group.save, "Saved zone_system_talk_group without system_talk_group"
    assert_includes zone_system_talk_group.errors[:system_talk_group], "must exist"
  end

  # Association Tests
  test "should belong to zone_system" do
    zone_system_talk_group = build(:zone_system_talk_group)
    assert_respond_to zone_system_talk_group, :zone_system
  end

  test "zone_system association should be configured" do
    association = ZoneSystemTalkGroup.reflect_on_association(:zone_system)
    assert_not_nil association, "zone_system association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should belong to system_talk_group" do
    zone_system_talk_group = build(:zone_system_talk_group)
    assert_respond_to zone_system_talk_group, :system_talk_group
  end

  test "system_talk_group association should be configured" do
    association = ZoneSystemTalkGroup.reflect_on_association(:system_talk_group)
    assert_not_nil association, "system_talk_group association should exist"
    assert_equal :belongs_to, association.macro
  end

  # Uniqueness Tests
  test "should not save zone_system_talk_group with duplicate system_talk_group in same zone_system" do
    zone_system = create(:zone_system)
    system_talk_group = create(:system_talk_group, system: zone_system.system)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_talk_group)

    duplicate = build(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_talk_group)
    assert_not duplicate.save, "Saved zone_system_talk_group with duplicate system_talk_group"
    assert_includes duplicate.errors[:system_talk_group_id], "has already been taken"
  end

  test "should save zone_system_talk_group with same system_talk_group in different zone_systems" do
    zone1 = create(:zone)
    zone2 = create(:zone)
    system = create(:system)
    zone_system1 = create(:zone_system, zone: zone1, system: system)
    zone_system2 = create(:zone_system, zone: zone2, system: system)
    system_talk_group = create(:system_talk_group, system: system)

    zstg1 = create(:zone_system_talk_group, zone_system: zone_system1, system_talk_group: system_talk_group)
    zstg2 = build(:zone_system_talk_group, zone_system: zone_system2, system_talk_group: system_talk_group)

    assert zstg2.save, "Failed to save same system_talk_group in different zone_system"
  end

  # Custom Validation: system_talk_group must belong to same system as zone_system
  test "should save zone_system_talk_group when system_talk_group belongs to zone_system's system" do
    system = create(:system)
    zone_system = create(:zone_system, system: system)
    system_talk_group = create(:system_talk_group, system: system)

    zstg = build(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_talk_group)
    assert zstg.save, "Failed to save when system_talk_group belongs to correct system"
  end

  test "should not save zone_system_talk_group when system_talk_group belongs to different system" do
    system1 = create(:system, name: "System 1")
    system2 = create(:system, name: "System 2")
    zone_system = create(:zone_system, system: system1)
    system_talk_group = create(:system_talk_group, system: system2)

    zstg = build(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_talk_group)
    assert_not zstg.save, "Saved when system_talk_group belongs to different system"
    assert_includes zstg.errors[:system_talk_group], "must belong to the same system as the zone system"
  end

  # Multiple ZoneSystemTalkGroups per ZoneSystem
  test "zone_system can have multiple zone_system_talk_groups" do
    system = create(:system)
    zone_system = create(:zone_system, system: system)
    stg1 = create(:system_talk_group, system: system, talk_group: create(:talk_group, name: "TG1"))
    stg2 = create(:system_talk_group, system: system, talk_group: create(:talk_group, name: "TG2"))
    stg3 = create(:system_talk_group, system: system, talk_group: create(:talk_group, name: "TG3"))

    zstg1 = create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: stg1)
    zstg2 = create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: stg2)
    zstg3 = create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: stg3)

    assert_equal 3, zone_system.zone_system_talkgroups.count
    assert_includes zone_system.zone_system_talkgroups, zstg1
    assert_includes zone_system.zone_system_talkgroups, zstg2
    assert_includes zone_system.zone_system_talkgroups, zstg3
  end

  # Through Association Tests
  test "zone_system should have system_talkgroups through zone_system_talkgroups" do
    system = create(:system)
    zone_system = create(:zone_system, system: system)
    stg1 = create(:system_talk_group, system: system, talk_group: create(:talk_group, name: "TG1"))
    stg2 = create(:system_talk_group, system: system, talk_group: create(:talk_group, name: "TG2"))

    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: stg1)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: stg2)

    assert_equal 2, zone_system.system_talkgroups.count
    assert_includes zone_system.system_talkgroups, stg1
    assert_includes zone_system.system_talkgroups, stg2
  end
end
