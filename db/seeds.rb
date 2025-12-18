# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Only seed development data in development environment
if Rails.env.development?
  puts "\n=== Seeding development data ==="

  # Create seed user
  # Credentials documented in README.md
  user = User.find_or_create_by!(email: "dev@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
    u.name = "Dev User"
    u.callsign = "W1DEV"
    u.default_power_level = "medium"
    u.measurement_preference = "imperial"
  end
  puts "Created seed user: #{user.email}"

  # Create system manufacturers (read-only, shared with all users)
  manufacturers_data = [
    "Motorola",
    "Baofeng",
    "Anytone",
    "TYT",
    "Kenwood",
    "Icom",
    "Yaesu",
    "Hytera",
    "Wouxun",
    "Radioddity"
  ]

  manufacturers = manufacturers_data.map do |name|
    manufacturer = Manufacturer.find_or_initialize_by(name: name)
    manufacturer.system_record = true
    manufacturer.user_id = nil
    manufacturer.save!
    manufacturer
  end
  puts "Created #{manufacturers.count} system manufacturers"

  # Create system radio models (read-only, shared with all users)
  radio_models_data = [
    # Motorola DMR radios
    {
      manufacturer: "Motorola",
      name: "XPR 7550",
      supported_modes: [ "analog", "dmr" ],
      max_zones: 250,
      max_channels_per_zone: 16,
      long_channel_name_length: 16,
      short_channel_name_length: 16,
      long_zone_name_length: 16,
      short_zone_name_length: 16,
      frequency_ranges: [
        { band: "UHF", min: 403.0, max: 470.0 }
      ]
    },
    {
      manufacturer: "Motorola",
      name: "XPR 6550",
      supported_modes: [ "analog", "dmr" ],
      max_zones: 250,
      max_channels_per_zone: 16,
      long_channel_name_length: 16,
      short_channel_name_length: 16,
      long_zone_name_length: 16,
      short_zone_name_length: 16,
      frequency_ranges: [
        { band: "VHF", min: 136.0, max: 174.0 }
      ]
    },

    # Anytone DMR radios
    {
      manufacturer: "Anytone",
      name: "D878UV Plus",
      supported_modes: [ "analog", "dmr" ],
      max_zones: 250,
      max_channels_per_zone: 250,
      long_channel_name_length: 16,
      short_channel_name_length: 16,
      long_zone_name_length: 16,
      short_zone_name_length: 16,
      frequency_ranges: [
        { band: "2m", min: 144.0, max: 148.0 },
        { band: "70cm", min: 420.0, max: 450.0 }
      ]
    },
    {
      manufacturer: "Anytone",
      name: "D578UV III Plus",
      supported_modes: [ "analog", "dmr" ],
      max_zones: 250,
      max_channels_per_zone: 250,
      long_channel_name_length: 16,
      short_channel_name_length: 16,
      long_zone_name_length: 16,
      short_zone_name_length: 16,
      frequency_ranges: [
        { band: "2m", min: 144.0, max: 148.0 },
        { band: "70cm", min: 420.0, max: 450.0 }
      ]
    },

    # TYT DMR radios
    {
      manufacturer: "TYT",
      name: "MD-UV380",
      supported_modes: [ "analog", "dmr" ],
      max_zones: 250,
      max_channels_per_zone: 64,
      long_channel_name_length: 16,
      short_channel_name_length: 8,
      long_zone_name_length: 16,
      short_zone_name_length: 8,
      frequency_ranges: [
        { band: "2m", min: 144.0, max: 148.0 },
        { band: "70cm", min: 420.0, max: 450.0 }
      ]
    },

    # Baofeng analog radios
    {
      manufacturer: "Baofeng",
      name: "UV-5R",
      supported_modes: [ "analog" ],
      max_zones: 1,
      max_channels_per_zone: 128,
      long_channel_name_length: 7,
      short_channel_name_length: 7,
      long_zone_name_length: 7,
      short_zone_name_length: 7,
      frequency_ranges: [
        { band: "2m", min: 144.0, max: 148.0 },
        { band: "70cm", min: 420.0, max: 450.0 }
      ]
    },

    # Kenwood analog/digital
    {
      manufacturer: "Kenwood",
      name: "TK-D740",
      supported_modes: [ "analog", "nxdn" ],
      max_zones: 128,
      max_channels_per_zone: 512,
      long_channel_name_length: 14,
      short_channel_name_length: 14,
      long_zone_name_length: 14,
      short_zone_name_length: 14,
      frequency_ranges: [
        { band: "VHF", min: 136.0, max: 174.0 }
      ]
    },

    # Icom analog
    {
      manufacturer: "Icom",
      name: "IC-V86",
      supported_modes: [ "analog" ],
      max_zones: 26,
      max_channels_per_zone: 200,
      long_channel_name_length: 8,
      short_channel_name_length: 8,
      long_zone_name_length: 8,
      short_zone_name_length: 8,
      frequency_ranges: [
        { band: "2m", min: 144.0, max: 148.0 }
      ]
    },

    # Yaesu analog
    {
      manufacturer: "Yaesu",
      name: "FT-60R",
      supported_modes: [ "analog" ],
      max_zones: 1,
      max_channels_per_zone: 1000,
      long_channel_name_length: 8,
      short_channel_name_length: 8,
      long_zone_name_length: 8,
      short_zone_name_length: 8,
      frequency_ranges: [
        { band: "2m", min: 144.0, max: 148.0 },
        { band: "70cm", min: 420.0, max: 450.0 }
      ]
    },

    # Hytera DMR
    {
      manufacturer: "Hytera",
      name: "PD782G",
      supported_modes: [ "analog", "dmr" ],
      max_zones: 250,
      max_channels_per_zone: 32,
      long_channel_name_length: 16,
      short_channel_name_length: 16,
      long_zone_name_length: 16,
      short_zone_name_length: 16,
      frequency_ranges: [
        { band: "VHF", min: 136.0, max: 174.0 }
      ]
    }
  ]

  radio_models_data.each do |data|
    manufacturer = Manufacturer.find_by!(name: data[:manufacturer])
    radio_model = RadioModel.find_or_initialize_by(manufacturer: manufacturer, name: data[:name])
    radio_model.supported_modes = data[:supported_modes]
    radio_model.max_zones = data[:max_zones]
    radio_model.max_channels_per_zone = data[:max_channels_per_zone]
    radio_model.long_channel_name_length = data[:long_channel_name_length]
    radio_model.short_channel_name_length = data[:short_channel_name_length]
    radio_model.long_zone_name_length = data[:long_zone_name_length]
    radio_model.short_zone_name_length = data[:short_zone_name_length]
    radio_model.frequency_ranges = data[:frequency_ranges]
    radio_model.system_record = true
    radio_model.user_id = nil
    radio_model.save!
  end
  puts "Created #{radio_models_data.count} system radio models"

  # Create networks for DMR talkgroups
  networks_data = [
    { name: "Brandmeister", network_type: "Digital-DMR", description: "Worldwide DMR network" },
    { name: "TGIF", network_type: "Digital-DMR", description: "The Global Internet of Friends" },
    { name: "P25 Network", network_type: "Digital-P25", description: "Project 25 digital network" }
  ]

  networks = networks_data.map do |data|
    network = Network.find_or_create_by!(name: data[:name]) do |n|
      n.network_type = data[:network_type]
      n.description = data[:description]
    end
    network
  end
  puts "Created #{networks.count} networks"

  # Create some sample systems (repeaters)
  dmr_network = Network.find_by!(name: "Brandmeister")

  # Analog system
  analog_detail = AnalogModeDetail.find_or_create_by!(id: AnalogModeDetail.maximum(:id).to_i + 1)
  analog_system = System.find_or_create_by!(name: "W1DEV Analog Repeater") do |s|
    s.mode = "analog"
    s.rx_frequency = 146.82
    s.tx_frequency = 146.22
    s.supports_tx_tone = true
    s.tx_tone_value = "127.3"
    s.supports_rx_tone = true
    s.rx_tone_value = "127.3"
    s.mode_detail = analog_detail
  end
  puts "Created analog system: #{analog_system.name}"

  # DMR system
  dmr_detail = DmrModeDetail.find_or_create_by!(color_code: 3) do |d|
    d.id = DmrModeDetail.maximum(:id).to_i + 1
  end
  dmr_system = System.find_or_create_by!(name: "W1DEV DMR Repeater") do |s|
    s.mode = "dmr"
    s.rx_frequency = 446.5
    s.tx_frequency = 441.5
    s.mode_detail = dmr_detail
  end
  # Associate DMR system with network
  unless dmr_system.networks.include?(dmr_network)
    dmr_system.networks << dmr_network
  end
  puts "Created DMR system: #{dmr_system.name}"

  # Create talkgroups
  talkgroups_data = [
    { name: "Local", talkgroup_number: "3100", network: dmr_network },
    { name: "TAC 310", talkgroup_number: "310", network: dmr_network },
    { name: "North America", talkgroup_number: "3", network: dmr_network }
  ]

  talkgroups = talkgroups_data.map do |data|
    TalkGroup.find_or_create_by!(network: data[:network], talkgroup_number: data[:talkgroup_number]) do |tg|
      tg.name = data[:name]
    end
  end
  puts "Created #{talkgroups.count} talkgroups"

  # Create SystemTalkGroups (talkgroups available on the DMR system)
  stg_data = [
    { talk_group: TalkGroup.find_by!(name: "Local"), timeslot: 1 },
    { talk_group: TalkGroup.find_by!(name: "TAC 310"), timeslot: 2 },
    { talk_group: TalkGroup.find_by!(name: "North America"), timeslot: 1 }
  ]

  stg_data.each do |data|
    SystemTalkGroup.find_or_create_by!(
      system: dmr_system,
      talk_group: data[:talk_group],
      timeslot: data[:timeslot]
    )
  end
  puts "Created #{stg_data.count} system talkgroups"

  # Create standalone zones (new architecture)
  # Zone 1: Local analog repeaters
  analog_zone = Zone.find_or_create_by!(user: user, name: "Local Analog") do |z|
    z.long_name = "Local Analog Repeaters"
    z.short_name = "ANALG"
    z.public = false
  end

  # Add analog system to zone
  unless analog_zone.zone_systems.exists?(system: analog_system)
    ZoneSystem.create!(zone: analog_zone, system: analog_system, position: 1)
  end
  puts "Created zone: #{analog_zone.name} with #{analog_zone.zone_systems.count} system(s)"

  # Zone 2: DMR with talkgroups
  dmr_zone = Zone.find_or_create_by!(user: user, name: "DMR Repeaters") do |z|
    z.long_name = "DMR Repeater Zone"
    z.short_name = "DMR"
    z.public = false
  end

  # Add DMR system to zone
  zone_system = dmr_zone.zone_systems.find_or_create_by!(system: dmr_system) do |zs|
    zs.position = 1
  end

  # Add talkgroups to zone_system
  stg_data.each do |data|
    stg = SystemTalkGroup.find_by!(system: dmr_system, talk_group: data[:talk_group])
    unless zone_system.zone_system_talkgroups.exists?(system_talk_group: stg)
      ZoneSystemTalkGroup.create!(zone_system: zone_system, system_talk_group: stg)
    end
  end
  puts "Created zone: #{dmr_zone.name} with #{dmr_zone.zone_systems.count} system(s) and #{zone_system.zone_system_talkgroups.count} talkgroups"

  # Create a public zone for sharing
  public_zone = Zone.find_or_create_by!(user: user, name: "Sample Public Zone") do |z|
    z.long_name = "Sample Public Zone"
    z.short_name = "PUB"
    z.public = true
  end
  puts "Created public zone: #{public_zone.name}"

  # Create a codeplug and add zones to it (new architecture)
  codeplug = Codeplug.find_or_create_by!(user: user, name: "My First Codeplug") do |c|
    c.description = "A sample codeplug demonstrating the zone architecture"
    c.public = false
  end

  # Add zones to codeplug via CodeplugZone
  [ analog_zone, dmr_zone ].each_with_index do |zone, index|
    CodeplugZone.find_or_create_by!(codeplug: codeplug, zone: zone) do |cz|
      cz.position = index + 1
    end
  end
  puts "Created codeplug: #{codeplug.name} with #{codeplug.codeplug_zones.count} zone(s)"

  # Generate channels from zones
  if codeplug.channels.empty?
    generator = ChannelGenerator.new(codeplug)
    result = generator.generate_channels
    puts "Generated #{result[:channels_created]} channel(s) from #{result[:zones_processed]} zone(s)"
  else
    puts "Codeplug already has #{codeplug.channels.count} channel(s)"
  end

  puts "\n=== Seed data complete ==="
  puts "Login with: dev@example.com / password123"
  puts "Run 'rails db:seed' again to update seed data (idempotent)"
end
