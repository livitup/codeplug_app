require "test_helper"

class SystemTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save system with valid attributes" do
    system = build(:system)
    assert system.save, "Failed to save system with valid attributes"
  end

  test "should not save system without name" do
    system = build(:system, name: nil)
    assert_not system.save, "Saved system without name"
    assert_includes system.errors[:name], "can't be blank"
  end

  test "should not save system without mode" do
    system = build(:system, mode: nil)
    assert_not system.save, "Saved system without mode"
    assert_includes system.errors[:mode], "can't be blank"
  end

  test "should not save system without tx_frequency" do
    system = build(:system, tx_frequency: nil)
    assert_not system.save, "Saved system without tx_frequency"
    assert_includes system.errors[:tx_frequency], "can't be blank"
  end

  test "should not save system without rx_frequency" do
    system = build(:system, rx_frequency: nil)
    assert_not system.save, "Saved system without rx_frequency"
    assert_includes system.errors[:rx_frequency], "can't be blank"
  end

  test "should not save DMR system without color_code" do
    system = build(:system, mode: "dmr", color_code: nil)
    assert_not system.save, "Saved DMR system without color_code"
    assert_includes system.errors[:color_code], "is not a number"
  end

  # Mode Enum Tests
  test "should save system with analog mode" do
    system = build(:system, mode: "analog")
    assert system.save, "Failed to save system with analog mode"
  end

  test "should save system with dmr mode" do
    system = build(:system, mode: "dmr")
    assert system.save, "Failed to save system with dmr mode"
  end

  test "should save system with p25 mode" do
    system = build(:system, :p25)
    assert system.save, "Failed to save system with p25 mode"
  end

  test "should save system with nxdn mode" do
    system = build(:system, :nxdn)
    assert system.save, "Failed to save system with nxdn mode"
  end

  test "should not save system with invalid mode" do
    system = build(:system, mode: "invalid_mode")
    assert_not system.save, "Saved system with invalid mode"
    assert_includes system.errors[:mode], "invalid_mode is not a valid mode"
  end

  # Polymorphic Association Tests
  test "should belong to mode_detail polymorphically" do
    system = build(:system)
    assert_respond_to system, :mode_detail
  end

  test "mode_detail association should be polymorphic" do
    association = System.reflect_on_association(:mode_detail)
    assert_not_nil association, "mode_detail association should exist"
    assert_equal :belongs_to, association.macro
    assert association.options[:polymorphic], "mode_detail should be polymorphic"
  end

  test "should work with DmrModeDetail" do
    dmr_detail = create(:dmr_mode_detail, color_code: 1)
    system = build(:system, mode: "dmr", mode_detail: dmr_detail)
    assert system.save, "Failed to save system with DmrModeDetail"
    assert_equal dmr_detail, system.mode_detail
    assert_equal "DmrModeDetail", system.mode_detail_type
  end

  test "should work with P25ModeDetail" do
    system = build(:system, :p25)
    assert system.save, "Failed to save system with P25ModeDetail"
    assert_instance_of P25ModeDetail, system.mode_detail
    assert_equal "P25ModeDetail", system.mode_detail_type
  end

  test "should work with AnalogModeDetail" do
    analog_detail = create(:analog_mode_detail)
    system = build(:system, mode: "analog", mode_detail: analog_detail)
    assert system.save, "Failed to save system with AnalogModeDetail"
    assert_equal analog_detail, system.mode_detail
    assert_equal "AnalogModeDetail", system.mode_detail_type
  end

  # Frequency Tests
  test "should save simplex system with same tx and rx frequencies" do
    system = build(:system, tx_frequency: 146.52, rx_frequency: 146.52)
    assert system.save, "Failed to save simplex system"
  end

  test "should save repeater system with different tx and rx frequencies" do
    system = build(:system, tx_frequency: 145.230, rx_frequency: 144.630)
    assert system.save, "Failed to save repeater system"
  end

  # Tone Tests
  test "should allow nil tone values" do
    system = build(:system, tx_tone_value: nil, rx_tone_value: nil)
    assert system.save, "Failed to save system with nil tone values"
  end

  test "should save system with CTCSS tone values" do
    system = build(:system,
      supports_tx_tone: true,
      tx_tone_value: "127.3",
      supports_rx_tone: true,
      rx_tone_value: "127.3")
    assert system.save, "Failed to save system with CTCSS tones"
  end

  test "should save system with DCS tone values" do
    system = build(:system,
      supports_tx_tone: true,
      tx_tone_value: "065",
      supports_rx_tone: false)
    assert system.save, "Failed to save system with DCS tone"
  end

  # Location Tests
  test "should allow nil location fields" do
    system = build(:system, city: nil, state: nil, county: nil, latitude: nil, longitude: nil)
    assert system.save, "Failed to save system with nil location"
  end

  test "should save system with location data" do
    system = build(:system,
      city: "Richmond",
      state: "Virginia",
      county: "Henrico",
      latitude: 37.5407,
      longitude: -77.4360)
    assert system.save, "Failed to save system with location"
  end

  # Bandwidth Tests
  test "BANDWIDTHS constant should be defined" do
    assert_equal [ "12.5 kHz", "20 kHz", "25 kHz" ], System::BANDWIDTHS
  end

  test "BANDWIDTHS constant should be frozen" do
    assert System::BANDWIDTHS.frozen?
  end

  test "should allow nil bandwidth" do
    system = build(:system, bandwidth: nil)
    assert system.save, "Failed to save system with nil bandwidth"
  end

  test "should save system with valid bandwidth values" do
    System::BANDWIDTHS.each do |bw|
      system = build(:system, bandwidth: bw)
      assert system.save, "Failed to save system with bandwidth: #{bw}"
    end
  end

  # Boolean Defaults Tests
  test "supports_tx_tone should default to false" do
    system = System.new
    assert_equal false, system.supports_tx_tone
  end

  test "supports_rx_tone should default to false" do
    system = System.new
    assert_equal false, system.supports_rx_tone
  end
end
