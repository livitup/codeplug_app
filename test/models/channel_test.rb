require "test_helper"

class ChannelTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save channel with valid attributes" do
    channel = build(:channel)
    assert channel.save, "Failed to save channel with valid attributes"
  end

  test "should not save channel without codeplug" do
    channel = build(:channel, codeplug: nil)
    assert_not channel.save, "Saved channel without codeplug"
    assert_includes channel.errors[:codeplug], "must exist"
  end

  test "should not save channel without system" do
    channel = build(:channel, system: nil)
    assert_not channel.save, "Saved channel without system"
    assert_includes channel.errors[:system], "must exist"
  end

  test "should not save channel without name" do
    channel = build(:channel, name: nil)
    assert_not channel.save, "Saved channel without name"
    assert_includes channel.errors[:name], "can't be blank"
  end

  # Optional Attribute Tests
  test "should save channel without system_talk_group" do
    channel = build(:channel, system_talk_group: nil)
    assert channel.save, "Failed to save channel without system_talk_group"
  end

  test "should save channel without long_name" do
    channel = build(:channel, long_name: nil)
    assert channel.save, "Failed to save channel without long_name"
  end

  test "should save channel without short_name" do
    channel = build(:channel, short_name: nil)
    assert channel.save, "Failed to save channel without short_name"
  end

  test "should save channel without bandwidth" do
    channel = build(:channel, bandwidth: nil)
    assert channel.save, "Failed to save channel without bandwidth"
  end

  test "BANDWIDTHS constant should be defined" do
    assert_equal [ "12.5 kHz", "20 kHz", "25 kHz" ], Channel::BANDWIDTHS
  end

  test "BANDWIDTHS constant should be frozen" do
    assert Channel::BANDWIDTHS.frozen?
  end

  test "should save channel with valid bandwidth values" do
    Channel::BANDWIDTHS.each do |bw|
      channel = build(:channel, bandwidth: bw)
      assert channel.save, "Failed to save channel with bandwidth: #{bw}"
    end
  end

  # Association Tests
  test "should belong to codeplug" do
    channel = build(:channel)
    assert_respond_to channel, :codeplug
  end

  test "codeplug association should be configured" do
    association = Channel.reflect_on_association(:codeplug)
    assert_not_nil association, "codeplug association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should belong to system" do
    channel = build(:channel)
    assert_respond_to channel, :system
  end

  test "system association should be configured" do
    association = Channel.reflect_on_association(:system)
    assert_not_nil association, "system association should exist"
    assert_equal :belongs_to, association.macro
  end

  test "should belong to system_talk_group optionally" do
    channel = build(:channel)
    assert_respond_to channel, :system_talk_group
  end

  test "system_talk_group association should be configured as optional" do
    association = Channel.reflect_on_association(:system_talk_group)
    assert_not_nil association, "system_talk_group association should exist"
    assert_equal :belongs_to, association.macro
    assert association.options[:optional], "system_talk_group should be optional"
  end

  test "should have many channel_zones" do
    channel = create(:channel)
    assert_respond_to channel, :channel_zones
  end

  test "channel_zones association should be configured with dependent destroy" do
    association = Channel.reflect_on_association(:channel_zones)
    assert_not_nil association, "channel_zones association should exist"
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
  end

  test "should have many zones through channel_zones" do
    channel = create(:channel)
    assert_respond_to channel, :zones
  end

  test "zones association should be configured as through" do
    association = Channel.reflect_on_association(:zones)
    assert_not_nil association, "zones association should exist"
    assert_equal :has_many, association.macro
    assert_equal :channel_zones, association.options[:through]
  end

  # Enum Tests - tone_mode
  test "should accept valid tone_mode values" do
    [ "none", "tx_only", "rx_only", "tx_rx" ].each do |mode|
      channel = build(:channel, tone_mode: mode)
      assert channel.save, "Failed to save channel with tone_mode: #{mode}"
    end
  end

  test "should not accept invalid tone_mode values" do
    channel = build(:channel, tone_mode: "invalid")
    assert_not channel.save, "Saved channel with invalid tone_mode"
    assert_includes channel.errors[:tone_mode], "'invalid' is not a valid tone_mode"
  end

  test "should default tone_mode to none" do
    channel = build(:channel)
    channel.save
    assert_equal "none", channel.tone_mode
  end

  # Enum Tests - transmit_permission
  test "should accept valid transmit_permission values" do
    [ "allow", "forbid_tx" ].each do |permission|
      channel = build(:channel, transmit_permission: permission)
      assert channel.save, "Failed to save channel with transmit_permission: #{permission}"
    end
  end

  test "should not accept invalid transmit_permission values" do
    channel = build(:channel, transmit_permission: "invalid")
    assert_not channel.save, "Saved channel with invalid transmit_permission"
    assert_includes channel.errors[:transmit_permission], "'invalid' is not a valid transmit_permission"
  end

  test "should default transmit_permission to allow" do
    channel = build(:channel)
    channel.save
    assert_equal "allow", channel.transmit_permission
  end

  # Attribute Storage Tests
  test "should store name" do
    channel = create(:channel, name: "Repeater 1")
    assert_equal "Repeater 1", channel.name
  end

  test "should store long_name" do
    channel = create(:channel, long_name: "Local Repeater Channel 1")
    assert_equal "Local Repeater Channel 1", channel.long_name
  end

  test "should store short_name" do
    channel = create(:channel, short_name: "RPT1")
    assert_equal "RPT1", channel.short_name
  end

  test "should store power_level" do
    channel = create(:channel, power_level: "High")
    assert_equal "High", channel.power_level
  end

  test "should store bandwidth" do
    channel = create(:channel, bandwidth: "25kHz")
    assert_equal "25kHz", channel.bandwidth
  end

  # Multiple Channels per Codeplug
  test "codeplug can have multiple channels" do
    codeplug = create(:codeplug)
    channel1 = create(:channel, codeplug: codeplug, name: "Channel 1")
    channel2 = create(:channel, codeplug: codeplug, name: "Channel 2")

    assert_equal 2, codeplug.channels.count
    assert_includes codeplug.channels, channel1
    assert_includes codeplug.channels, channel2
  end

  # Same name in different codeplugs
  test "different codeplugs can have channels with same name" do
    codeplug1 = create(:codeplug)
    codeplug2 = create(:codeplug)
    channel1 = create(:channel, codeplug: codeplug1, name: "Repeater")
    channel2 = create(:channel, codeplug: codeplug2, name: "Repeater")

    assert channel1.persisted?
    assert channel2.persisted?
  end

  # System TalkGroup Tests
  test "should save digital channel with system_talk_group" do
    # Create DMR system with network association
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_system = create(:system, mode: "dmr", color_code: 1)
    dmr_system.networks << dmr_network
    talkgroup = create(:talk_group, network: dmr_network)
    system_talk_group = create(:system_talk_group, system: dmr_system, talk_group: talkgroup, timeslot: 1)
    channel = build(:channel, system: dmr_system, system_talk_group: system_talk_group)

    assert channel.save, "Failed to save digital channel with system_talk_group"
  end

  test "should save analog channel without system_talk_group" do
    analog_system = create(:system, :analog)
    channel = build(:channel, system: analog_system, system_talk_group: nil)

    assert channel.save, "Failed to save analog channel without system_talk_group"
  end
end
