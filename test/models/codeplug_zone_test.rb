require "test_helper"

class CodeplugZoneTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save codeplug_zone with valid attributes" do
    codeplug_zone = build(:codeplug_zone)
    assert codeplug_zone.save, "Failed to save codeplug_zone with valid attributes"
  end

  test "should not save codeplug_zone without codeplug" do
    codeplug_zone = build(:codeplug_zone, codeplug: nil)
    assert_not codeplug_zone.save, "Saved codeplug_zone without codeplug"
    assert_includes codeplug_zone.errors[:codeplug], "must exist"
  end

  test "should not save codeplug_zone without zone" do
    codeplug_zone = build(:codeplug_zone, zone: nil)
    assert_not codeplug_zone.save, "Saved codeplug_zone without zone"
    assert_includes codeplug_zone.errors[:zone], "must exist"
  end

  test "should not save codeplug_zone without position" do
    codeplug_zone = build(:codeplug_zone, position: nil)
    assert_not codeplug_zone.save, "Saved codeplug_zone without position"
    assert_includes codeplug_zone.errors[:position], "can't be blank"
  end

  # Association Tests
  test "should belong to codeplug" do
    codeplug_zone = build(:codeplug_zone)
    assert_respond_to codeplug_zone, :codeplug
  end

  test "codeplug association should be configured" do
    association = CodeplugZone.reflect_on_association(:codeplug)
    assert_not_nil association, "codeplug association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should belong to zone" do
    codeplug_zone = build(:codeplug_zone)
    assert_respond_to codeplug_zone, :zone
  end

  test "zone association should be configured" do
    association = CodeplugZone.reflect_on_association(:zone)
    assert_not_nil association, "zone association should exist"
    assert_equal :belongs_to, association.macro
  end

  # Position Validation Tests
  test "should save codeplug_zone with position 1" do
    codeplug_zone = build(:codeplug_zone, position: 1)
    assert codeplug_zone.save, "Failed to save codeplug_zone with position 1"
  end

  test "should save codeplug_zone with large position" do
    codeplug_zone = build(:codeplug_zone, position: 1000)
    assert codeplug_zone.save, "Failed to save codeplug_zone with large position"
  end

  test "should not save codeplug_zone with position 0" do
    codeplug_zone = build(:codeplug_zone, position: 0)
    assert_not codeplug_zone.save, "Saved codeplug_zone with position 0"
    assert_includes codeplug_zone.errors[:position], "must be greater than 0"
  end

  test "should not save codeplug_zone with negative position" do
    codeplug_zone = build(:codeplug_zone, position: -1)
    assert_not codeplug_zone.save, "Saved codeplug_zone with negative position"
    assert_includes codeplug_zone.errors[:position], "must be greater than 0"
  end

  # Uniqueness Tests
  test "should not save codeplug_zone with duplicate zone in same codeplug" do
    codeplug = create(:codeplug)
    zone = create(:zone, codeplug: codeplug)
    create(:codeplug_zone, codeplug: codeplug, zone: zone, position: 1)

    duplicate = build(:codeplug_zone, codeplug: codeplug, zone: zone, position: 2)
    assert_not duplicate.save, "Saved codeplug_zone with duplicate zone in same codeplug"
    assert_includes duplicate.errors[:zone_id], "has already been taken"
  end

  test "should save codeplug_zone with same zone in different codeplugs" do
    codeplug1 = create(:codeplug)
    codeplug2 = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug1)
    zone2 = create(:zone, codeplug: codeplug2)

    cz1 = create(:codeplug_zone, codeplug: codeplug1, zone: zone1, position: 1)
    cz2 = build(:codeplug_zone, codeplug: codeplug2, zone: zone2, position: 1)

    assert cz2.save, "Failed to save same zone in different codeplug"
  end

  test "should not save codeplug_zone with duplicate position in same codeplug" do
    codeplug = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug, name: "Zone 1")
    zone2 = create(:zone, codeplug: codeplug, name: "Zone 2")
    create(:codeplug_zone, codeplug: codeplug, zone: zone1, position: 1)

    duplicate = build(:codeplug_zone, codeplug: codeplug, zone: zone2, position: 1)
    assert_not duplicate.save, "Saved codeplug_zone with duplicate position in same codeplug"
    assert_includes duplicate.errors[:position], "has already been taken"
  end

  test "should save codeplug_zone with same position in different codeplugs" do
    codeplug1 = create(:codeplug)
    codeplug2 = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug1)
    zone2 = create(:zone, codeplug: codeplug2)

    cz1 = create(:codeplug_zone, codeplug: codeplug1, zone: zone1, position: 1)
    cz2 = build(:codeplug_zone, codeplug: codeplug2, zone: zone2, position: 1)

    assert cz2.save, "Failed to save codeplug_zone with same position in different codeplug"
  end

  # Position Storage Tests
  test "should store position as integer" do
    codeplug_zone = create(:codeplug_zone, position: 42)
    assert_equal 42, codeplug_zone.position
  end

  # Multiple CodeplugZones per Codeplug
  test "codeplug can have multiple codeplug_zones at different positions" do
    codeplug = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug, name: "Zone 1")
    zone2 = create(:zone, codeplug: codeplug, name: "Zone 2")
    zone3 = create(:zone, codeplug: codeplug, name: "Zone 3")

    cz1 = create(:codeplug_zone, codeplug: codeplug, zone: zone1, position: 1)
    cz2 = create(:codeplug_zone, codeplug: codeplug, zone: zone2, position: 2)
    cz3 = create(:codeplug_zone, codeplug: codeplug, zone: zone3, position: 3)

    assert_equal 3, codeplug.codeplug_zones.count
    assert_includes codeplug.codeplug_zones, cz1
    assert_includes codeplug.codeplug_zones, cz2
    assert_includes codeplug.codeplug_zones, cz3
  end

  # Default Scope - Ordering by Position
  test "codeplug_zones should be ordered by position by default" do
    codeplug = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug, name: "Zone 1")
    zone2 = create(:zone, codeplug: codeplug, name: "Zone 2")
    zone3 = create(:zone, codeplug: codeplug, name: "Zone 3")

    # Create in non-sequential order
    cz3 = create(:codeplug_zone, codeplug: codeplug, zone: zone3, position: 3)
    cz1 = create(:codeplug_zone, codeplug: codeplug, zone: zone1, position: 1)
    cz2 = create(:codeplug_zone, codeplug: codeplug, zone: zone2, position: 2)

    # Should be returned in position order
    assert_equal [ cz1, cz2, cz3 ], codeplug.codeplug_zones.to_a
  end

  # Through Association Tests
  test "codeplug should have zones through codeplug_zones" do
    codeplug = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug, name: "Zone 1")
    zone2 = create(:zone, codeplug: codeplug, name: "Zone 2")

    create(:codeplug_zone, codeplug: codeplug, zone: zone1, position: 1)
    create(:codeplug_zone, codeplug: codeplug, zone: zone2, position: 2)

    assert_equal 2, codeplug.zones.count
    assert_includes codeplug.zones, zone1
    assert_includes codeplug.zones, zone2
  end

  test "zone should have codeplugs through codeplug_zones" do
    zone = create(:zone)
    codeplug1 = create(:codeplug)
    codeplug2 = create(:codeplug)

    create(:codeplug_zone, zone: zone, codeplug: codeplug1, position: 1)
    create(:codeplug_zone, zone: zone, codeplug: codeplug2, position: 1)

    assert_equal 2, zone.codeplugs.count
    assert_includes zone.codeplugs, codeplug1
    assert_includes zone.codeplugs, codeplug2
  end
end
