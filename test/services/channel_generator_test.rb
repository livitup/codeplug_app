require "test_helper"

class ChannelGeneratorTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @codeplug = create(:codeplug, user: @user)
  end

  # Basic initialization tests
  test "initializes with codeplug" do
    generator = ChannelGenerator.new(@codeplug)
    assert_equal @codeplug, generator.codeplug
  end

  # Analog system tests
  test "generates one channel per analog system" do
    zone = create(:zone, user: @user, name: "Analog Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system1 = create(:system, :analog, name: "W4BK Repeater")
    analog_system2 = create(:system, :analog, name: "K4BMI Repeater")
    create(:zone_system, zone: zone, system: analog_system1, position: 1)
    create(:zone_system, zone: zone, system: analog_system2, position: 2)

    generator = ChannelGenerator.new(@codeplug)

    assert_difference "Channel.count", 2 do
      generator.generate_channels
    end

    channels = @codeplug.channels.reload
    assert_equal 2, channels.count
    assert_equal [ analog_system1.id, analog_system2.id ], channels.map(&:system_id)
  end

  test "analog channel has nil system_talk_group" do
    zone = create(:zone, user: @user, name: "Analog Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    channel = @codeplug.channels.first
    assert_nil channel.system_talk_group
  end

  test "analog channel name is derived from system name" do
    zone = create(:zone, user: @user, name: "Analog Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    channel = @codeplug.channels.first
    assert_equal "W4BK Repeater", channel.long_name
    assert_equal "W4BK Repeater", channel.name
  end

  # Digital system tests
  test "generates one channel per talkgroup for digital systems" do
    zone = create(:zone, user: @user, name: "DMR Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    # Create DMR system with network and talkgroups
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_system = create(:system, mode: "dmr", name: "W4BK DMR", color_code: 1)
    dmr_system.networks << dmr_network

    talkgroup1 = create(:talk_group, network: dmr_network, name: "Virginia", talkgroup_number: "3151")
    talkgroup2 = create(:talk_group, network: dmr_network, name: "Worldwide", talkgroup_number: "91")

    system_tg1 = create(:system_talk_group, system: dmr_system, talk_group: talkgroup1, timeslot: 1)
    system_tg2 = create(:system_talk_group, system: dmr_system, talk_group: talkgroup2, timeslot: 2)

    zone_system = create(:zone_system, zone: zone, system: dmr_system, position: 1)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_tg1)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_tg2)

    generator = ChannelGenerator.new(@codeplug)

    assert_difference "Channel.count", 2 do
      generator.generate_channels
    end

    channels = @codeplug.channels.reload
    assert_equal 2, channels.count
    assert channels.all? { |c| c.system == dmr_system }
    assert_equal [ system_tg1.id, system_tg2.id ].sort, channels.map(&:system_talk_group_id).sort
  end

  test "digital channel name includes system and talkgroup name" do
    zone = create(:zone, user: @user, name: "DMR Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_system = create(:system, mode: "dmr", name: "W4BK DMR", color_code: 1)
    dmr_system.networks << dmr_network

    talkgroup = create(:talk_group, network: dmr_network, name: "Virginia", talkgroup_number: "3151")
    system_tg = create(:system_talk_group, system: dmr_system, talk_group: talkgroup, timeslot: 1)

    zone_system = create(:zone_system, zone: zone, system: dmr_system, position: 1)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_tg)

    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    channel = @codeplug.channels.first
    assert_equal "W4BK DMR - Virginia", channel.long_name
    assert_includes channel.name, "Virginia"
  end

  test "digital system with no talkgroups selected generates no channels" do
    zone = create(:zone, user: @user, name: "DMR Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    dmr_system = create(:system, mode: "dmr", name: "W4BK DMR", color_code: 1)
    create(:zone_system, zone: zone, system: dmr_system, position: 1)
    # Note: no zone_system_talkgroups created

    generator = ChannelGenerator.new(@codeplug)

    assert_no_difference "Channel.count" do
      generator.generate_channels
    end
  end

  # P25 system tests
  test "generates channels for P25 systems" do
    zone = create(:zone, user: @user, name: "P25 Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    p25_network = create(:network, :p25_network)
    p25_system = create(:system, :p25, name: "VARA P25")

    talkgroup = create(:talk_group, network: p25_network, name: "Virginia P25", talkgroup_number: "12345")
    system_tg = create(:system_talk_group, system: p25_system, talk_group: talkgroup, timeslot: nil)

    zone_system = create(:zone_system, zone: zone, system: p25_system, position: 1)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_tg)

    generator = ChannelGenerator.new(@codeplug)

    assert_difference "Channel.count", 1 do
      generator.generate_channels
    end

    channel = @codeplug.channels.first
    assert_equal p25_system, channel.system
    assert_equal system_tg, channel.system_talk_group
  end

  # Mixed zone tests
  test "handles zones with mix of analog and digital systems" do
    zone = create(:zone, user: @user, name: "Mixed Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    # Analog system
    analog_system = create(:system, :analog, name: "Analog Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    # DMR system with 2 talkgroups
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_system = create(:system, mode: "dmr", name: "DMR Repeater", color_code: 1)
    dmr_system.networks << dmr_network

    talkgroup1 = create(:talk_group, network: dmr_network, name: "Local", talkgroup_number: "3101")
    talkgroup2 = create(:talk_group, network: dmr_network, name: "TAC 1", talkgroup_number: "8951")

    system_tg1 = create(:system_talk_group, system: dmr_system, talk_group: talkgroup1, timeslot: 1)
    system_tg2 = create(:system_talk_group, system: dmr_system, talk_group: talkgroup2, timeslot: 2)

    zone_system = create(:zone_system, zone: zone, system: dmr_system, position: 2)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_tg1)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: system_tg2)

    generator = ChannelGenerator.new(@codeplug)

    assert_difference "Channel.count", 3 do
      generator.generate_channels
    end

    channels = @codeplug.channels.reload
    analog_channels = channels.select { |c| c.system == analog_system }
    digital_channels = channels.select { |c| c.system == dmr_system }

    assert_equal 1, analog_channels.count
    assert_equal 2, digital_channels.count
  end

  # Multiple zones tests
  test "generates channels for multiple zones in correct order" do
    zone1 = create(:zone, user: @user, name: "Zone 1")
    zone2 = create(:zone, user: @user, name: "Zone 2")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone1, position: 1)
    create(:codeplug_zone, codeplug: @codeplug, zone: zone2, position: 2)

    analog_system1 = create(:system, :analog, name: "System 1")
    analog_system2 = create(:system, :analog, name: "System 2")
    create(:zone_system, zone: zone1, system: analog_system1, position: 1)
    create(:zone_system, zone: zone2, system: analog_system2, position: 1)

    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    channels = @codeplug.channels.reload
    assert_equal 2, channels.count
  end

  # ChannelZone tests
  test "creates ChannelZone records for generated channels" do
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    generator = ChannelGenerator.new(@codeplug)

    assert_difference "ChannelZone.count", 1 do
      generator.generate_channels
    end

    channel = @codeplug.channels.first
    channel_zone = ChannelZone.find_by(channel: channel, zone: zone)
    assert_not_nil channel_zone
    assert_equal 1, channel_zone.position
  end

  test "channel positions are sequential within each zone" do
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    # Create 3 analog systems
    analog_system1 = create(:system, :analog, name: "System 1")
    analog_system2 = create(:system, :analog, name: "System 2")
    analog_system3 = create(:system, :analog, name: "System 3")
    create(:zone_system, zone: zone, system: analog_system1, position: 1)
    create(:zone_system, zone: zone, system: analog_system2, position: 2)
    create(:zone_system, zone: zone, system: analog_system3, position: 3)

    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    channel_zones = ChannelZone.where(zone: zone).order(:position)
    assert_equal [ 1, 2, 3 ], channel_zones.map(&:position)
  end

  test "channels in different zones have independent position numbering" do
    zone1 = create(:zone, user: @user, name: "Zone 1")
    zone2 = create(:zone, user: @user, name: "Zone 2")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone1, position: 1)
    create(:codeplug_zone, codeplug: @codeplug, zone: zone2, position: 2)

    analog_system1 = create(:system, :analog, name: "System 1")
    analog_system2 = create(:system, :analog, name: "System 2")
    create(:zone_system, zone: zone1, system: analog_system1, position: 1)
    create(:zone_system, zone: zone2, system: analog_system2, position: 1)

    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    zone1_channel_zones = ChannelZone.where(zone: zone1)
    zone2_channel_zones = ChannelZone.where(zone: zone2)

    assert_equal [ 1 ], zone1_channel_zones.map(&:position)
    assert_equal [ 1 ], zone2_channel_zones.map(&:position)
  end

  # Empty and edge case tests
  test "handles codeplug with no zones" do
    generator = ChannelGenerator.new(@codeplug)

    assert_no_difference "Channel.count" do
      result = generator.generate_channels
    end
  end

  test "handles zone with no systems" do
    zone = create(:zone, user: @user, name: "Empty Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    generator = ChannelGenerator.new(@codeplug)

    assert_no_difference "Channel.count" do
      generator.generate_channels
    end
  end

  # Regeneration tests
  test "regenerate destroys existing channels and creates new ones" do
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    # Create initial channels
    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    assert_equal 1, @codeplug.channels.count
    original_channel_id = @codeplug.channels.first.id

    # Regenerate
    generator.generate_channels(regenerate: true)

    @codeplug.reload
    assert_equal 1, @codeplug.channels.count
    assert_not_equal original_channel_id, @codeplug.channels.first.id
  end

  test "regenerate false does not create channels if channels already exist" do
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    # Create initial channels
    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    original_channel_id = @codeplug.channels.first.id

    # Try to generate again without regenerate flag
    result = generator.generate_channels(regenerate: false)

    @codeplug.reload
    assert_equal 1, @codeplug.channels.count
    assert_equal original_channel_id, @codeplug.channels.first.id
    assert result[:skipped], "Should have skipped generation"
  end

  test "regenerate also destroys ChannelZone records" do
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    # Create initial channels
    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    original_channel_zone_count = ChannelZone.count

    # Regenerate
    generator.generate_channels(regenerate: true)

    # ChannelZone count should be same (old ones destroyed, new ones created)
    assert_equal original_channel_zone_count, ChannelZone.count
  end

  # Return value tests
  test "returns summary with channel count" do
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    generator = ChannelGenerator.new(@codeplug)
    result = generator.generate_channels

    assert_kind_of Hash, result
    assert_equal 1, result[:channels_created]
    assert_equal 1, result[:channel_zones_created]
    assert_equal false, result[:skipped]
  end

  test "returns summary with zone breakdown" do
    zone1 = create(:zone, user: @user, name: "Zone 1")
    zone2 = create(:zone, user: @user, name: "Zone 2")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone1, position: 1)
    create(:codeplug_zone, codeplug: @codeplug, zone: zone2, position: 2)

    analog_system1 = create(:system, :analog, name: "System 1")
    analog_system2 = create(:system, :analog, name: "System 2")
    analog_system3 = create(:system, :analog, name: "System 3")
    create(:zone_system, zone: zone1, system: analog_system1, position: 1)
    create(:zone_system, zone: zone1, system: analog_system2, position: 2)
    create(:zone_system, zone: zone2, system: analog_system3, position: 1)

    generator = ChannelGenerator.new(@codeplug)
    result = generator.generate_channels

    assert_equal 3, result[:channels_created]
    assert_equal 3, result[:channel_zones_created]
    assert_equal 2, result[:zones_processed]
  end

  # Channel attribute defaults tests
  test "generated channels have default attributes" do
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    channel = @codeplug.channels.first
    assert_equal "none", channel.tone_mode
    assert_equal "allow", channel.transmit_permission
  end

  # Name truncation test
  test "generates short_name as truncated version of long_name" do
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    analog_system = create(:system, :analog, name: "Very Long Repeater Name That Exceeds Limits")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    channel = @codeplug.channels.first
    assert channel.short_name.present?
    assert channel.short_name.length <= 8
  end

  # System order preservation test
  test "preserves zone_system position order when generating channels" do
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)

    # Create systems in non-alphabetical order
    analog_system_c = create(:system, :analog, name: "Charlie")
    analog_system_a = create(:system, :analog, name: "Alpha")
    analog_system_b = create(:system, :analog, name: "Bravo")

    # Add to zone in specific position order: B, C, A
    create(:zone_system, zone: zone, system: analog_system_b, position: 1)
    create(:zone_system, zone: zone, system: analog_system_c, position: 2)
    create(:zone_system, zone: zone, system: analog_system_a, position: 3)

    generator = ChannelGenerator.new(@codeplug)
    generator.generate_channels

    channel_zones = ChannelZone.where(zone: zone).order(:position).includes(:channel)
    channel_names = channel_zones.map { |cz| cz.channel.long_name }

    assert_equal [ "Bravo", "Charlie", "Alpha" ], channel_names
  end
end
