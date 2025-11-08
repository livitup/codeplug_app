require "test_helper"

class ZoneSystemTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save zone_system with valid attributes" do
    zone_system = build(:zone_system)
    assert zone_system.save, "Failed to save zone_system with valid attributes"
  end

  test "should not save zone_system without zone" do
    zone_system = build(:zone_system, zone: nil)
    assert_not zone_system.save, "Saved zone_system without zone"
    assert_includes zone_system.errors[:zone], "must exist"
  end

  test "should not save zone_system without system" do
    zone_system = build(:zone_system, system: nil)
    assert_not zone_system.save, "Saved zone_system without system"
    assert_includes zone_system.errors[:system], "must exist"
  end

  test "should not save zone_system without position" do
    zone_system = build(:zone_system, position: nil)
    assert_not zone_system.save, "Saved zone_system without position"
    assert_includes zone_system.errors[:position], "can't be blank"
  end

  # Association Tests
  test "should belong to zone" do
    zone_system = build(:zone_system)
    assert_respond_to zone_system, :zone
  end

  test "zone association should be configured" do
    association = ZoneSystem.reflect_on_association(:zone)
    assert_not_nil association, "zone association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should belong to system" do
    zone_system = build(:zone_system)
    assert_respond_to zone_system, :system
  end

  test "system association should be configured" do
    association = ZoneSystem.reflect_on_association(:system)
    assert_not_nil association, "system association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should have many zone_system_talkgroups" do
    zone_system = build(:zone_system)
    assert_respond_to zone_system, :zone_system_talkgroups
  end

  test "zone_system_talkgroups association should be configured with dependent destroy" do
    association = ZoneSystem.reflect_on_association(:zone_system_talkgroups)
    assert_not_nil association, "zone_system_talkgroups association should exist"
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
  end

  test "should have many system_talkgroups through zone_system_talkgroups" do
    zone_system = build(:zone_system)
    assert_respond_to zone_system, :system_talkgroups
  end

  test "system_talkgroups association should be configured" do
    association = ZoneSystem.reflect_on_association(:system_talkgroups)
    assert_not_nil association, "system_talkgroups association should exist"
    assert_equal :has_many, association.macro
    assert_equal :zone_system_talkgroups, association.options[:through]
  end

  # Position Validation Tests
  test "should save zone_system with position 1" do
    zone_system = build(:zone_system, position: 1)
    assert zone_system.save, "Failed to save zone_system with position 1"
  end

  test "should save zone_system with large position" do
    zone_system = build(:zone_system, position: 1000)
    assert zone_system.save, "Failed to save zone_system with large position"
  end

  test "should not save zone_system with position 0" do
    zone_system = build(:zone_system, position: 0)
    assert_not zone_system.save, "Saved zone_system with position 0"
    assert_includes zone_system.errors[:position], "must be greater than 0"
  end

  test "should not save zone_system with negative position" do
    zone_system = build(:zone_system, position: -1)
    assert_not zone_system.save, "Saved zone_system with negative position"
    assert_includes zone_system.errors[:position], "must be greater than 0"
  end

  # Uniqueness Tests
  test "should not save zone_system with duplicate system in same zone" do
    zone = create(:zone)
    system = create(:system)
    create(:zone_system, zone: zone, system: system, position: 1)

    duplicate = build(:zone_system, zone: zone, system: system, position: 2)
    assert_not duplicate.save, "Saved zone_system with duplicate system in same zone"
    assert_includes duplicate.errors[:system_id], "has already been taken"
  end

  test "should save zone_system with same system in different zones" do
    zone1 = create(:zone)
    zone2 = create(:zone)
    system = create(:system)

    zs1 = create(:zone_system, zone: zone1, system: system, position: 1)
    zs2 = build(:zone_system, zone: zone2, system: system, position: 1)

    assert zs2.save, "Failed to save same system in different zones"
  end

  test "should not save zone_system with duplicate position in same zone" do
    zone = create(:zone)
    system1 = create(:system)
    system2 = create(:system, name: "System 2")
    create(:zone_system, zone: zone, system: system1, position: 1)

    duplicate = build(:zone_system, zone: zone, system: system2, position: 1)
    assert_not duplicate.save, "Saved zone_system with duplicate position in same zone"
    assert_includes duplicate.errors[:position], "has already been taken"
  end

  test "should save zone_system with same position in different zones" do
    zone1 = create(:zone)
    zone2 = create(:zone)
    system1 = create(:system)
    system2 = create(:system, name: "System 2")

    zs1 = create(:zone_system, zone: zone1, system: system1, position: 1)
    zs2 = build(:zone_system, zone: zone2, system: system2, position: 1)

    assert zs2.save, "Failed to save zone_system with same position in different zone"
  end

  # Position Storage Tests
  test "should store position as integer" do
    zone_system = create(:zone_system, position: 42)
    assert_equal 42, zone_system.position
  end

  # Multiple ZoneSystems per Zone
  test "zone can have multiple zone_systems at different positions" do
    zone = create(:zone)
    system1 = create(:system, name: "System 1")
    system2 = create(:system, name: "System 2")
    system3 = create(:system, name: "System 3")

    zs1 = create(:zone_system, zone: zone, system: system1, position: 1)
    zs2 = create(:zone_system, zone: zone, system: system2, position: 2)
    zs3 = create(:zone_system, zone: zone, system: system3, position: 3)

    assert_equal 3, zone.zone_systems.count
    assert_includes zone.zone_systems, zs1
    assert_includes zone.zone_systems, zs2
    assert_includes zone.zone_systems, zs3
  end

  # Through Association Tests
  test "zone should have systems through zone_systems" do
    zone = create(:zone)
    system1 = create(:system, name: "System 1")
    system2 = create(:system, name: "System 2")

    create(:zone_system, zone: zone, system: system1, position: 1)
    create(:zone_system, zone: zone, system: system2, position: 2)

    assert_equal 2, zone.systems.count
    assert_includes zone.systems, system1
    assert_includes zone.systems, system2
  end
end
