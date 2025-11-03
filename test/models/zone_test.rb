require "test_helper"

class ZoneTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save zone with valid attributes" do
    zone = build(:zone)
    assert zone.save, "Failed to save zone with valid attributes"
  end

  test "should not save zone without codeplug" do
    zone = build(:zone, codeplug: nil)
    assert_not zone.save, "Saved zone without codeplug"
    assert_includes zone.errors[:codeplug], "must exist"
  end

  test "should not save zone without name" do
    zone = build(:zone, name: nil)
    assert_not zone.save, "Saved zone without name"
    assert_includes zone.errors[:name], "can't be blank"
  end

  test "should save zone with empty long_name" do
    zone = build(:zone, long_name: nil)
    assert zone.save, "Failed to save zone with nil long_name"
  end

  test "should save zone with empty short_name" do
    zone = build(:zone, short_name: nil)
    assert zone.save, "Failed to save zone with nil short_name"
  end

  # Association Tests
  test "should belong to codeplug" do
    zone = build(:zone)
    assert_respond_to zone, :codeplug
  end

  test "codeplug association should be configured" do
    association = Zone.reflect_on_association(:codeplug)
    assert_not_nil association, "codeplug association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should have many channel_zones" do
    zone = create(:zone)
    assert_respond_to zone, :channel_zones
  end

  test "channel_zones association should be configured with dependent destroy" do
    association = Zone.reflect_on_association(:channel_zones)
    assert_not_nil association, "channel_zones association should exist"
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
  end

  test "should have many channels through channel_zones" do
    zone = create(:zone)
    assert_respond_to zone, :channels
  end

  test "channels association should be configured as through" do
    association = Zone.reflect_on_association(:channels)
    assert_not_nil association, "channels association should exist"
    assert_equal :has_many, association.macro
    assert_equal :channel_zones, association.options[:through]
  end

  # Dependent Destroy Tests
  test "destroying zone should destroy associated channel_zones" do
    zone = create(:zone)
    # Note: ChannelZone will be created in a later issue, so this test will fail until then
    # For now, we're just testing the association configuration exists
    skip "ChannelZone model not yet implemented"
  end

  # Attribute Tests
  test "should store name as string" do
    zone = create(:zone, name: "Repeaters")
    assert_equal "Repeaters", zone.name
  end

  test "should store long_name as string" do
    zone = create(:zone, long_name: "Local Repeaters Zone")
    assert_equal "Local Repeaters Zone", zone.long_name
  end

  test "should store short_name as string" do
    zone = create(:zone, short_name: "RPT")
    assert_equal "RPT", zone.short_name
  end

  test "should allow different zones with same name in different codeplugs" do
    codeplug1 = create(:codeplug)
    codeplug2 = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug1, name: "Zone A")
    zone2 = create(:zone, codeplug: codeplug2, name: "Zone A")

    assert zone1.persisted?
    assert zone2.persisted?
  end

  # Multiple Zones per Codeplug
  test "codeplug can have multiple zones" do
    codeplug = create(:codeplug)
    zone1 = create(:zone, codeplug: codeplug, name: "Zone 1")
    zone2 = create(:zone, codeplug: codeplug, name: "Zone 2")

    assert_equal 2, codeplug.zones.count
    assert_includes codeplug.zones, zone1
    assert_includes codeplug.zones, zone2
  end

  # Name Length Tests (no validation, just storage)
  test "should store long names" do
    long_name = "A" * 100
    zone = create(:zone, name: long_name)
    assert_equal long_name, zone.name
  end

  test "should store long long_name" do
    long_long_name = "B" * 100
    zone = create(:zone, long_name: long_long_name)
    assert_equal long_long_name, zone.long_name
  end

  test "should store short short_name" do
    zone = create(:zone, short_name: "AB")
    assert_equal "AB", zone.short_name
  end
end
