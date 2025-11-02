require "test_helper"

class DmrModeDetailTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save dmr mode detail with valid attributes" do
    dmr_mode_detail = build(:dmr_mode_detail)
    assert dmr_mode_detail.save, "Failed to save dmr mode detail with valid attributes"
  end

  test "should not save dmr mode detail without color_code" do
    dmr_mode_detail = build(:dmr_mode_detail, color_code: nil)
    assert_not dmr_mode_detail.save, "Saved dmr mode detail without color_code"
    assert_includes dmr_mode_detail.errors[:color_code], "can't be blank"
  end

  # Color Code Range Tests
  test "should save dmr mode detail with color_code 0" do
    dmr_mode_detail = build(:dmr_mode_detail, color_code: 0)
    assert dmr_mode_detail.save, "Failed to save with color_code 0"
  end

  test "should save dmr mode detail with color_code 15" do
    dmr_mode_detail = build(:dmr_mode_detail, color_code: 15)
    assert dmr_mode_detail.save, "Failed to save with color_code 15"
  end

  test "should save dmr mode detail with color_code in range" do
    dmr_mode_detail = build(:dmr_mode_detail, color_code: 7)
    assert dmr_mode_detail.save, "Failed to save with color_code in valid range"
  end

  test "should not save dmr mode detail with color_code below 0" do
    dmr_mode_detail = build(:dmr_mode_detail, color_code: -1)
    assert_not dmr_mode_detail.save, "Saved dmr mode detail with color_code below 0"
    assert_includes dmr_mode_detail.errors[:color_code], "must be greater than or equal to 0"
  end

  test "should not save dmr mode detail with color_code above 15" do
    dmr_mode_detail = build(:dmr_mode_detail, color_code: 16)
    assert_not dmr_mode_detail.save, "Saved dmr mode detail with color_code above 15"
    assert_includes dmr_mode_detail.errors[:color_code], "must be less than or equal to 15"
  end

  test "should not save dmr mode detail with non-integer color_code" do
    dmr_mode_detail = build(:dmr_mode_detail, color_code: "abc")
    assert_not dmr_mode_detail.valid?, "Validated dmr mode detail with non-integer color_code"
  end

  # Type Tests
  test "color_code should be integer" do
    dmr_mode_detail = build(:dmr_mode_detail, color_code: 5)
    assert dmr_mode_detail.save
    assert_kind_of Integer, dmr_mode_detail.color_code
  end
end
