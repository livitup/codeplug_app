class ChannelGenerator
  attr_reader :codeplug

  def initialize(codeplug)
    @codeplug = codeplug
  end

  def generate_channels(regenerate: false)
    # Check if channels already exist and regenerate is false
    if codeplug.channels.any? && !regenerate
      return {
        channels_created: 0,
        channel_zones_created: 0,
        zones_processed: 0,
        skipped: true
      }
    end

    # If regenerating, destroy existing channels (ChannelZones are destroyed via dependent: :destroy)
    codeplug.channels.destroy_all if regenerate

    channels_created = 0
    channel_zones_created = 0
    zones_processed = 0

    # Process each zone in the codeplug (ordered by position via default_scope)
    codeplug.codeplug_zones.includes(zone: { zone_systems: [ :system, { zone_system_talkgroups: { system_talk_group: :talk_group } } ] }).each do |codeplug_zone|
      zone = codeplug_zone.zone
      zones_processed += 1
      channel_position = 1

      # Process each system in the zone (ordered by position)
      zone.zone_systems.order(:position).each do |zone_system|
        system = zone_system.system

        if digital_system?(system)
          # For digital systems, create one channel per talkgroup
          zone_system.zone_system_talkgroups.includes(system_talk_group: :talk_group).each do |zone_system_talkgroup|
            system_talk_group = zone_system_talkgroup.system_talk_group
            channel = create_digital_channel(system, system_talk_group, zone)

            if channel.persisted?
              create_channel_zone(channel, zone, channel_position)
              channels_created += 1
              channel_zones_created += 1
              channel_position += 1
            end
          end
        else
          # For analog systems, create one channel per system
          channel = create_analog_channel(system, zone)

          if channel.persisted?
            create_channel_zone(channel, zone, channel_position)
            channels_created += 1
            channel_zones_created += 1
            channel_position += 1
          end
        end
      end
    end

    {
      channels_created: channels_created,
      channel_zones_created: channel_zones_created,
      zones_processed: zones_processed,
      skipped: false
    }
  end

  private

  def digital_system?(system)
    %w[dmr p25 nxdn].include?(system.mode)
  end

  def create_analog_channel(system, source_zone)
    codeplug.channels.create!(
      system: system,
      source_zone: source_zone,
      name: system.name,
      long_name: system.name,
      short_name: generate_short_name(system.name),
      tone_mode: "none",
      transmit_permission: "allow"
    )
  end

  def create_digital_channel(system, system_talk_group, source_zone)
    talkgroup_name = system_talk_group.talk_group.name
    long_name = "#{system.name} - #{talkgroup_name}"

    codeplug.channels.create!(
      system: system,
      system_talk_group: system_talk_group,
      source_zone: source_zone,
      name: talkgroup_name,
      long_name: long_name,
      short_name: generate_short_name(talkgroup_name),
      tone_mode: "none",
      transmit_permission: "allow"
    )
  end

  def create_channel_zone(channel, zone, position)
    ChannelZone.create!(
      channel: channel,
      zone: zone,
      position: position
    )
  end

  def generate_short_name(name)
    # Truncate to 8 characters max for short_name
    name.to_s.gsub(/\s+/, "")[0, 8]
  end
end
