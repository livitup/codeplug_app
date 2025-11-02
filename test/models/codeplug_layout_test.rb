require "test_helper"

class CodeplugLayoutTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save codeplug layout with valid attributes" do
    codeplug_layout = build(:codeplug_layout)
    assert codeplug_layout.save, "Failed to save codeplug layout with valid attributes"
  end

  test "should not save codeplug layout without name" do
    codeplug_layout = build(:codeplug_layout, name: nil)
    assert_not codeplug_layout.save, "Saved codeplug layout without name"
    assert_includes codeplug_layout.errors[:name], "can't be blank"
  end

  test "should not save codeplug layout without radio_model" do
    codeplug_layout = build(:codeplug_layout, radio_model: nil)
    assert_not codeplug_layout.save, "Saved codeplug layout without radio_model"
    assert_includes codeplug_layout.errors[:radio_model], "must exist"
  end

  test "should not save codeplug layout without layout_definition" do
    codeplug_layout = build(:codeplug_layout, layout_definition: nil)
    assert_not codeplug_layout.save, "Saved codeplug layout without layout_definition"
    assert_includes codeplug_layout.errors[:layout_definition], "can't be blank"
  end

  test "should save codeplug layout with null user (system default)" do
    codeplug_layout = build(:codeplug_layout, user: nil)
    assert codeplug_layout.save, "Failed to save codeplug layout with null user"
  end

  test "should save codeplug layout with user (custom layout)" do
    user = create(:user)
    codeplug_layout = build(:codeplug_layout, user: user)
    assert codeplug_layout.save, "Failed to save codeplug layout with user"
  end

  # Association Tests
  test "should belong to radio_model" do
    radio_model = create(:radio_model)
    codeplug_layout = create(:codeplug_layout, radio_model: radio_model)
    assert_equal radio_model, codeplug_layout.radio_model
  end

  test "should belong to user optionally" do
    user = create(:user)
    codeplug_layout = create(:codeplug_layout, user: user)
    assert_equal user, codeplug_layout.user
  end

  test "should allow null user" do
    codeplug_layout = create(:codeplug_layout, user: nil)
    assert_nil codeplug_layout.user
  end

  # JSON Layout Definition Tests
  test "should save codeplug layout with valid JSON layout_definition" do
    layout_def = {
      "columns" => [
        { "header" => "Channel Name", "maps_to" => "long_name" },
        { "header" => "RX Freq", "maps_to" => "system.rx_frequency" }
      ]
    }
    codeplug_layout = build(:codeplug_layout, layout_definition: layout_def)
    assert codeplug_layout.save, "Failed to save with valid layout_definition"
  end

  test "should save codeplug layout with complex layout_definition" do
    layout_def = {
      "columns" => [
        { "header" => "Channel Name", "maps_to" => "long_name" },
        { "header" => "RX Freq", "maps_to" => "system.rx_frequency" },
        { "header" => "TX Freq", "maps_to" => "system.tx_frequency" },
        { "header" => "Power", "maps_to" => "power_level" },
        { "header" => "Talkgroup", "maps_to" => "system_talkgroup.talkgroup.name" }
      ]
    }
    codeplug_layout = build(:codeplug_layout, layout_definition: layout_def)
    assert codeplug_layout.save, "Failed to save with complex layout_definition"
  end

  # Serialization Tests
  test "should properly serialize and deserialize layout_definition" do
    layout_def = {
      "columns" => [
        { "header" => "Channel Name", "maps_to" => "long_name" },
        { "header" => "RX Freq", "maps_to" => "system.rx_frequency" }
      ]
    }
    codeplug_layout = create(:codeplug_layout, layout_definition: layout_def)
    codeplug_layout.reload
    assert_equal layout_def, codeplug_layout.layout_definition
  end

  test "should handle hash with symbol keys in layout_definition" do
    layout_def = {
      columns: [
        { header: "Channel Name", maps_to: "long_name" }
      ]
    }
    codeplug_layout = build(:codeplug_layout, layout_definition: layout_def)
    assert codeplug_layout.save, "Failed to save with symbol keys"
    codeplug_layout.reload
    # After saving and reloading, keys should be strings
    assert_equal "Channel Name", codeplug_layout.layout_definition["columns"][0]["header"]
  end

  # Uniqueness Tests
  test "should allow multiple layouts for same radio_model" do
    radio_model = create(:radio_model)
    layout1 = create(:codeplug_layout, radio_model: radio_model, name: "Layout 1")
    layout2 = build(:codeplug_layout, radio_model: radio_model, name: "Layout 2")
    assert layout2.save, "Should allow multiple layouts for same radio_model"
  end

  test "should allow same name for different radio_models" do
    radio_model1 = create(:radio_model)
    radio_model2 = create(:radio_model)
    layout1 = create(:codeplug_layout, radio_model: radio_model1, name: "CHIRP CSV")
    layout2 = build(:codeplug_layout, radio_model: radio_model2, name: "CHIRP CSV")
    assert layout2.save, "Should allow same name for different radio_models"
  end
end
