require "test_helper"

class ManufacturerTest < ActiveSupport::TestCase
  # Validation Tests
  test "should save manufacturer with valid name" do
    manufacturer = build(:manufacturer, name: "Motorola")
    assert manufacturer.save, "Failed to save manufacturer with valid name"
  end

  test "should not save manufacturer without name" do
    manufacturer = build(:manufacturer, name: nil)
    assert_not manufacturer.save, "Saved manufacturer without a name"
    assert_includes manufacturer.errors[:name], "can't be blank"
  end

  test "should not save manufacturer with empty name" do
    manufacturer = build(:manufacturer, name: "")
    assert_not manufacturer.save, "Saved manufacturer with empty name"
    assert_includes manufacturer.errors[:name], "can't be blank"
  end

  test "should not save manufacturer with duplicate name" do
    create(:manufacturer, name: "Baofeng")
    manufacturer = build(:manufacturer, name: "Baofeng")
    assert_not manufacturer.save, "Saved manufacturer with duplicate name"
    assert_includes manufacturer.errors[:name], "has already been taken"
  end

  test "should enforce case-insensitive uniqueness for name" do
    create(:manufacturer, name: "Kenwood")
    manufacturer = build(:manufacturer, name: "KENWOOD")
    assert_not manufacturer.save, "Saved manufacturer with duplicate name (different case)"
    assert_includes manufacturer.errors[:name], "has already been taken"
  end

  test "should allow different manufacturer names" do
    create(:manufacturer, name: "Motorola")
    manufacturer = build(:manufacturer, name: "Baofeng")
    assert manufacturer.save, "Failed to save manufacturer with different name"
  end

  # Association Tests
  test "should respond to radio_models association" do
    manufacturer = build(:manufacturer)
    assert_respond_to manufacturer, :radio_models, "Manufacturer should have radio_models association"
  end

  test "radio_models association should be configured" do
    manufacturer = build(:manufacturer)
    association = Manufacturer.reflect_on_association(:radio_models)
    assert_not_nil association, "radio_models association should exist"
    assert_equal :has_many, association.macro, "radio_models should be a has_many association"
  end

  # Additional attribute tests
  test "should trim whitespace from name" do
    manufacturer = create(:manufacturer, name: "  Icom  ")
    assert_equal "Icom", manufacturer.name, "Name should have whitespace trimmed"
  end
end
