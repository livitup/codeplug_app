require "test_helper"

class RadioModelTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save radio model with valid attributes" do
    radio_model = build(:radio_model)
    assert radio_model.save, "Failed to save radio model with valid attributes"
  end

  test "should not save radio model without name" do
    radio_model = build(:radio_model, name: nil)
    assert_not radio_model.save, "Saved radio model without name"
    assert_includes radio_model.errors[:name], "can't be blank"
  end

  test "should not save radio model without manufacturer" do
    radio_model = build(:radio_model, manufacturer: nil)
    assert_not radio_model.save, "Saved radio model without manufacturer"
    assert_includes radio_model.errors[:manufacturer], "must exist"
  end

  test "should not save radio model without supported modes" do
    radio_model = build(:radio_model, supported_modes: nil)
    assert_not radio_model.save, "Saved radio model without supported modes"
    assert_includes radio_model.errors[:supported_modes], "can't be blank"
  end

  test "should not save radio model with empty supported modes array" do
    radio_model = build(:radio_model, supported_modes: [])
    assert_not radio_model.save, "Saved radio model with empty supported modes"
    assert_includes radio_model.errors[:supported_modes], "must have at least one mode"
  end

  test "should save radio model with valid supported modes" do
    radio_model = build(:radio_model, supported_modes: [ "analog", "dmr" ])
    assert radio_model.save, "Failed to save radio model with valid modes"
  end

  # Integer Validation Tests
  test "should not save radio model with negative max_zones" do
    radio_model = build(:radio_model, max_zones: -1)
    assert_not radio_model.save, "Saved radio model with negative max_zones"
    assert_includes radio_model.errors[:max_zones], "must be greater than 0"
  end

  test "should not save radio model with zero max_zones" do
    radio_model = build(:radio_model, max_zones: 0)
    assert_not radio_model.save, "Saved radio model with zero max_zones"
    assert_includes radio_model.errors[:max_zones], "must be greater than 0"
  end

  test "should save radio model with null max_zones (unlimited)" do
    radio_model = build(:radio_model, max_zones: nil)
    assert radio_model.save, "Failed to save radio model with null max_zones"
  end

  test "should not save radio model with negative max_channels_per_zone" do
    radio_model = build(:radio_model, max_channels_per_zone: -1)
    assert_not radio_model.save, "Saved radio model with negative max_channels_per_zone"
  end

  test "should not save radio model with zero max_channels_per_zone" do
    radio_model = build(:radio_model, max_channels_per_zone: 0)
    assert_not radio_model.save, "Saved radio model with zero max_channels_per_zone"
  end

  test "should not save radio model with negative long_channel_name_length" do
    radio_model = build(:radio_model, long_channel_name_length: -1)
    assert_not radio_model.save, "Saved radio model with negative name length"
  end

  test "should not save radio model with zero long_channel_name_length" do
    radio_model = build(:radio_model, long_channel_name_length: 0)
    assert_not radio_model.save, "Saved radio model with zero name length"
  end

  # Association Tests
  test "should belong to manufacturer" do
    manufacturer = create(:manufacturer)
    radio_model = create(:radio_model, manufacturer: manufacturer)
    assert_equal manufacturer, radio_model.manufacturer
  end

  test "should respond to codeplug_layouts association" do
    radio_model = build(:radio_model)
    assert_respond_to radio_model, :codeplug_layouts
  end

  test "codeplug_layouts association should be configured" do
    association = RadioModel.reflect_on_association(:codeplug_layouts)
    assert_not_nil association, "codeplug_layouts association should exist"
    assert_equal :has_many, association.macro
  end

  # Frequency Ranges Tests
  test "should save radio model with valid frequency ranges" do
    radio_model = build(:radio_model, frequency_ranges: [
      { band: "2m", min: 144.0, max: 148.0 },
      { band: "70cm", min: 420.0, max: 450.0 }
    ])
    assert radio_model.save, "Failed to save with valid frequency ranges"
  end

  test "should save radio model with empty frequency ranges" do
    radio_model = build(:radio_model, frequency_ranges: [])
    assert radio_model.save, "Failed to save with empty frequency ranges"
  end

  test "should save radio model with nil frequency ranges" do
    radio_model = build(:radio_model, frequency_ranges: nil)
    assert radio_model.save, "Failed to save with nil frequency ranges"
  end

  # Serialization Tests
  test "should properly serialize and deserialize frequency ranges" do
    ranges = [
      { "band" => "2m", "min" => 144.0, "max" => 148.0 },
      { "band" => "70cm", "min" => 420.0, "max" => 450.0 }
    ]
    radio_model = create(:radio_model, frequency_ranges: ranges)
    radio_model.reload
    assert_equal ranges, radio_model.frequency_ranges
  end

  test "should properly serialize and deserialize supported modes" do
    modes = [ "analog", "dmr", "p25" ]
    radio_model = create(:radio_model, supported_modes: modes)
    radio_model.reload
    assert_equal modes, radio_model.supported_modes
  end

  # User Association Tests
  test "should belong to user" do
    user = create(:user)
    radio_model = create(:radio_model, :user_owned, user: user)
    assert_equal user, radio_model.user
  end

  test "should allow nil user for system records" do
    radio_model = create(:radio_model, :system)
    assert_nil radio_model.user
    assert radio_model.system_record?
  end

  # System Record Tests
  test "system_record defaults to false" do
    radio_model = build(:radio_model)
    assert_equal false, radio_model.system_record
  end

  test "system records have no user" do
    radio_model = create(:radio_model, :system)
    assert radio_model.system_record?
    assert_nil radio_model.user_id
  end

  test "user-owned records have user and system_record false" do
    user = create(:user)
    radio_model = create(:radio_model, :user_owned, user: user)
    assert_not radio_model.system_record?
    assert_equal user, radio_model.user
  end

  # Scope Tests
  test "system scope returns only system records" do
    system_model = create(:radio_model, :system, name: "System Model")
    user = create(:user)
    user_model = create(:radio_model, :user_owned, user: user, name: "User Model")

    system_records = RadioModel.system
    assert_includes system_records, system_model
    assert_not_includes system_records, user_model
  end

  test "user_owned scope returns records for specific user" do
    user1 = create(:user)
    user2 = create(:user)
    model1 = create(:radio_model, :user_owned, user: user1, name: "User1 Model")
    model2 = create(:radio_model, :user_owned, user: user2, name: "User2 Model")
    system_model = create(:radio_model, :system, name: "System Model")

    user1_records = RadioModel.user_owned(user1)
    assert_includes user1_records, model1
    assert_not_includes user1_records, model2
    assert_not_includes user1_records, system_model
  end

  test "visible_to scope returns system records and user's own records" do
    user1 = create(:user)
    user2 = create(:user)
    system_model = create(:radio_model, :system, name: "System Model")
    user1_model = create(:radio_model, :user_owned, user: user1, name: "User1 Model")
    user2_model = create(:radio_model, :user_owned, user: user2, name: "User2 Model")

    visible_to_user1 = RadioModel.visible_to(user1)
    assert_includes visible_to_user1, system_model
    assert_includes visible_to_user1, user1_model
    assert_not_includes visible_to_user1, user2_model
  end

  # Authorization Method Tests
  test "editable_by? returns false for system records" do
    user = create(:user)
    radio_model = create(:radio_model, :system)
    assert_not radio_model.editable_by?(user)
  end

  test "editable_by? returns true for owner of user-owned record" do
    user = create(:user)
    radio_model = create(:radio_model, :user_owned, user: user)
    assert radio_model.editable_by?(user)
  end

  test "editable_by? returns false for non-owner of user-owned record" do
    owner = create(:user)
    other_user = create(:user)
    radio_model = create(:radio_model, :user_owned, user: owner)
    assert_not radio_model.editable_by?(other_user)
  end

  test "editable_by? returns false when user is nil" do
    radio_model = create(:radio_model, :user_owned)
    assert_not radio_model.editable_by?(nil)
  end
end
