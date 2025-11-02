require "test_helper"

class P25ModeDetailTest < ActiveSupport::TestCase
  # Basic Validation Tests
  test "should save p25 mode detail with valid attributes" do
    p25_mode_detail = build(:p25_mode_detail)
    assert p25_mode_detail.save, "Failed to save p25 mode detail with valid attributes"
  end

  test "should not save p25 mode detail without nac" do
    p25_mode_detail = build(:p25_mode_detail, nac: nil)
    assert_not p25_mode_detail.save, "Saved p25 mode detail without nac"
    assert_includes p25_mode_detail.errors[:nac], "can't be blank"
  end

  test "should not save p25 mode detail with blank nac" do
    p25_mode_detail = build(:p25_mode_detail, nac: "")
    assert_not p25_mode_detail.save, "Saved p25 mode detail with blank nac"
    assert_includes p25_mode_detail.errors[:nac], "can't be blank"
  end

  # NAC Format Tests
  test "should save p25 mode detail with numeric nac" do
    p25_mode_detail = build(:p25_mode_detail, nac: "293")
    assert p25_mode_detail.save, "Failed to save with numeric nac"
  end

  test "should save p25 mode detail with different nac values" do
    [ "001", "123", "999", "F7E" ].each do |nac_value|
      p25_mode_detail = build(:p25_mode_detail, nac: nac_value)
      assert p25_mode_detail.save, "Failed to save with nac: #{nac_value}"
    end
  end

  # Type Tests
  test "nac should be string" do
    p25_mode_detail = build(:p25_mode_detail, nac: "293")
    assert p25_mode_detail.save
    assert_kind_of String, p25_mode_detail.nac
  end
end
