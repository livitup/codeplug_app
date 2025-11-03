require "test_helper"

class ChannelZoneTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save channel_zone with valid attributes" do
    channel_zone = build(:channel_zone)
    assert channel_zone.save, "Failed to save channel_zone with valid attributes"
  end

  test "should not save channel_zone without channel" do
    channel_zone = build(:channel_zone, channel: nil)
    assert_not channel_zone.save, "Saved channel_zone without channel"
    assert_includes channel_zone.errors[:channel], "must exist"
  end

  test "should not save channel_zone without zone" do
    channel_zone = build(:channel_zone, zone: nil)
    assert_not channel_zone.save, "Saved channel_zone without zone"
    assert_includes channel_zone.errors[:zone], "must exist"
  end

  test "should not save channel_zone without position" do
    channel_zone = build(:channel_zone, position: nil)
    assert_not channel_zone.save, "Saved channel_zone without position"
    assert_includes channel_zone.errors[:position], "can't be blank"
  end

  # Association Tests
  test "should belong to channel" do
    channel_zone = build(:channel_zone)
    assert_respond_to channel_zone, :channel
  end

  test "channel association should be configured" do
    association = ChannelZone.reflect_on_association(:channel)
    assert_not_nil association, "channel association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should belong to zone" do
    channel_zone = build(:channel_zone)
    assert_respond_to channel_zone, :zone
  end

  test "zone association should be configured" do
    association = ChannelZone.reflect_on_association(:zone)
    assert_not_nil association, "zone association should exist"
    assert_equal :belongs_to, association.macro
  end

  # Position Validation Tests
  test "should save channel_zone with position 1" do
    channel_zone = build(:channel_zone, position: 1)
    assert channel_zone.save, "Failed to save channel_zone with position 1"
  end

  test "should save channel_zone with large position" do
    channel_zone = build(:channel_zone, position: 1000)
    assert channel_zone.save, "Failed to save channel_zone with large position"
  end

  test "should not save channel_zone with position 0" do
    channel_zone = build(:channel_zone, position: 0)
    assert_not channel_zone.save, "Saved channel_zone with position 0"
    assert_includes channel_zone.errors[:position], "must be greater than 0"
  end

  test "should not save channel_zone with negative position" do
    channel_zone = build(:channel_zone, position: -1)
    assert_not channel_zone.save, "Saved channel_zone with negative position"
    assert_includes channel_zone.errors[:position], "must be greater than 0"
  end

  # Uniqueness Tests
  test "should not save channel_zone with duplicate position in same zone" do
    zone = create(:zone)
    channel1 = create(:channel)
    create(:channel_zone, zone: zone, channel: channel1, position: 1)

    channel2 = create(:channel)
    duplicate = build(:channel_zone, zone: zone, channel: channel2, position: 1)
    assert_not duplicate.save, "Saved channel_zone with duplicate position in same zone"
    assert_includes duplicate.errors[:position], "has already been taken"
  end

  test "should save channel_zone with same position in different zones" do
    zone1 = create(:zone)
    zone2 = create(:zone)
    channel1 = create(:channel)
    channel2 = create(:channel)

    cz1 = create(:channel_zone, zone: zone1, channel: channel1, position: 1)
    cz2 = build(:channel_zone, zone: zone2, channel: channel2, position: 1)

    assert cz2.save, "Failed to save channel_zone with same position in different zone"
  end

  test "should save same channel at different positions in same zone" do
    zone = create(:zone)
    channel = create(:channel)

    cz1 = create(:channel_zone, zone: zone, channel: channel, position: 1)
    cz2 = build(:channel_zone, zone: zone, channel: channel, position: 2)

    assert cz2.save, "Failed to save same channel at different positions in same zone"
  end

  test "should save same channel at same position in different zones" do
    zone1 = create(:zone)
    zone2 = create(:zone)
    channel = create(:channel)

    cz1 = create(:channel_zone, zone: zone1, channel: channel, position: 1)
    cz2 = build(:channel_zone, zone: zone2, channel: channel, position: 1)

    assert cz2.save, "Failed to save same channel at same position in different zones"
  end

  # Position Storage Tests
  test "should store position as integer" do
    channel_zone = create(:channel_zone, position: 42)
    assert_equal 42, channel_zone.position
  end

  # Multiple ChannelZones per Zone
  test "zone can have multiple channel_zones at different positions" do
    zone = create(:zone)
    channel1 = create(:channel)
    channel2 = create(:channel)
    channel3 = create(:channel)

    cz1 = create(:channel_zone, zone: zone, channel: channel1, position: 1)
    cz2 = create(:channel_zone, zone: zone, channel: channel2, position: 2)
    cz3 = create(:channel_zone, zone: zone, channel: channel3, position: 3)

    assert_equal 3, zone.channel_zones.count
    assert_includes zone.channel_zones, cz1
    assert_includes zone.channel_zones, cz2
    assert_includes zone.channel_zones, cz3
  end

  # Multiple ChannelZones per Channel
  test "channel can have multiple channel_zones in different zones" do
    channel = create(:channel)
    zone1 = create(:zone)
    zone2 = create(:zone)
    zone3 = create(:zone)

    cz1 = create(:channel_zone, channel: channel, zone: zone1, position: 1)
    cz2 = create(:channel_zone, channel: channel, zone: zone2, position: 5)
    cz3 = create(:channel_zone, channel: channel, zone: zone3, position: 10)

    assert_equal 3, channel.channel_zones.count
    assert_includes channel.channel_zones, cz1
    assert_includes channel.channel_zones, cz2
    assert_includes channel.channel_zones, cz3
  end

  # Through Association Tests
  test "zone should have channels through channel_zones" do
    zone = create(:zone)
    channel1 = create(:channel)
    channel2 = create(:channel)

    create(:channel_zone, zone: zone, channel: channel1, position: 1)
    create(:channel_zone, zone: zone, channel: channel2, position: 2)

    assert_equal 2, zone.channels.count
    assert_includes zone.channels, channel1
    assert_includes zone.channels, channel2
  end

  test "channel should have zones through channel_zones" do
    channel = create(:channel)
    zone1 = create(:zone)
    zone2 = create(:zone)

    create(:channel_zone, channel: channel, zone: zone1, position: 1)
    create(:channel_zone, channel: channel, zone: zone2, position: 1)

    assert_equal 2, channel.zones.count
    assert_includes channel.zones, zone1
    assert_includes channel.zones, zone2
  end
end
