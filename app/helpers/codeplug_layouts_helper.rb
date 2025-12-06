module CodeplugLayoutsHelper
  # Returns an array of field groups with their available fields
  # Each group has: { name: "Category", fields: [{ label: "Display Name", maps_to: "field_path" }] }
  def available_source_fields
    [
      channel_fields,
      system_fields,
      zone_fields,
      talk_group_fields
    ]
  end

  # Returns available fields as JSON for JavaScript consumption
  def available_source_fields_json
    available_source_fields.to_json
  end

  # Generates a CSV preview line from columns array
  def generate_csv_preview(columns)
    return "" if columns.empty?

    headers = columns.map do |col|
      header = col["header"].to_s
      # Escape headers containing commas
      header.include?(",") ? "\"#{header}\"" : header
    end

    headers.join(",")
  end

  private

  def channel_fields
    {
      name: "Channel",
      fields: [
        { label: "Name", maps_to: "name" },
        { label: "Long Name", maps_to: "long_name" },
        { label: "Short Name", maps_to: "short_name" },
        { label: "Power Level", maps_to: "power_level" },
        { label: "Bandwidth", maps_to: "bandwidth" },
        { label: "Tone Mode", maps_to: "tone_mode" },
        { label: "Transmit Permission", maps_to: "transmit_permission" }
      ]
    }
  end

  def system_fields
    {
      name: "System",
      fields: [
        { label: "System Name", maps_to: "system.name" },
        { label: "RX Frequency", maps_to: "system.rx_frequency" },
        { label: "TX Frequency", maps_to: "system.tx_frequency" },
        { label: "Mode", maps_to: "system.mode" },
        { label: "TX Tone", maps_to: "system.tx_tone_value" },
        { label: "RX Tone", maps_to: "system.rx_tone_value" },
        { label: "Bandwidth", maps_to: "system.bandwidth" },
        { label: "City", maps_to: "system.city" },
        { label: "State", maps_to: "system.state" },
        { label: "County", maps_to: "system.county" },
        { label: "Latitude", maps_to: "system.latitude" },
        { label: "Longitude", maps_to: "system.longitude" }
      ]
    }
  end

  def zone_fields
    {
      name: "Zone",
      fields: [
        { label: "Zone Name", maps_to: "zone.name" },
        { label: "Zone Long Name", maps_to: "zone.long_name" },
        { label: "Zone Short Name", maps_to: "zone.short_name" }
      ]
    }
  end

  def talk_group_fields
    {
      name: "Talk Group",
      fields: [
        { label: "Talk Group Name", maps_to: "talk_group.name" },
        { label: "Talk Group Number", maps_to: "talk_group.talkgroup_number" },
        { label: "Timeslot", maps_to: "system_talk_group.timeslot" }
      ]
    }
  end
end
