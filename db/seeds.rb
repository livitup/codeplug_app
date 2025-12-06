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

  puts "\n=== Seed data complete ==="
  puts "Login with: dev@example.com / password123"
  puts "Run 'rails db:seed' again to update seed data (idempotent)"
end
