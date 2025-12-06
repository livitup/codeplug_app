require "test_helper"

class CodeplugLayoutsHelperTest < ActionView::TestCase
  include CodeplugLayoutsHelper

  test "available_source_fields returns an array of field groups" do
    fields = available_source_fields
    assert_kind_of Array, fields
    assert_not_empty fields
  end

  test "available_source_fields includes channel fields" do
    fields = available_source_fields
    channel_group = fields.find { |g| g[:name] == "Channel" }

    assert_not_nil channel_group
    assert_kind_of Array, channel_group[:fields]

    field_names = channel_group[:fields].map { |f| f[:maps_to] }
    assert_includes field_names, "name"
    assert_includes field_names, "long_name"
    assert_includes field_names, "short_name"
    assert_includes field_names, "tone_mode"
    assert_includes field_names, "transmit_permission"
  end

  test "available_source_fields includes system fields with system prefix" do
    fields = available_source_fields
    system_group = fields.find { |g| g[:name] == "System" }

    assert_not_nil system_group
    assert_kind_of Array, system_group[:fields]

    field_names = system_group[:fields].map { |f| f[:maps_to] }
    assert_includes field_names, "system.name"
    assert_includes field_names, "system.rx_frequency"
    assert_includes field_names, "system.tx_frequency"
    assert_includes field_names, "system.mode"
  end

  test "available_source_fields includes zone fields with zone prefix" do
    fields = available_source_fields
    zone_group = fields.find { |g| g[:name] == "Zone" }

    assert_not_nil zone_group
    assert_kind_of Array, zone_group[:fields]

    field_names = zone_group[:fields].map { |f| f[:maps_to] }
    assert_includes field_names, "zone.name"
    assert_includes field_names, "zone.long_name"
    assert_includes field_names, "zone.short_name"
  end

  test "each field has label and maps_to" do
    fields = available_source_fields
    fields.each do |group|
      group[:fields].each do |field|
        assert field[:label].present?, "Field should have a label"
        assert field[:maps_to].present?, "Field should have a maps_to"
      end
    end
  end

  test "available_source_fields_json returns valid JSON" do
    json = available_source_fields_json
    assert_kind_of String, json

    parsed = JSON.parse(json)
    assert_kind_of Array, parsed
    assert_not_empty parsed
  end

  test "generate_csv_preview returns comma-separated headers" do
    columns = [
      { "header" => "Channel Name", "maps_to" => "name" },
      { "header" => "RX Freq", "maps_to" => "system.rx_frequency" }
    ]

    preview = generate_csv_preview(columns)
    assert_equal "Channel Name,RX Freq", preview
  end

  test "generate_csv_preview handles empty columns" do
    preview = generate_csv_preview([])
    assert_equal "", preview
  end

  test "generate_csv_preview escapes commas in headers" do
    columns = [
      { "header" => "Name, Full", "maps_to" => "name" },
      { "header" => "RX Freq", "maps_to" => "system.rx_frequency" }
    ]

    preview = generate_csv_preview(columns)
    assert_equal '"Name, Full",RX Freq', preview
  end
end
