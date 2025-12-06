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

  # User Association Tests
  test "should belong to user" do
    user = create(:user)
    manufacturer = create(:manufacturer, :user_owned, user: user)
    assert_equal user, manufacturer.user
  end

  test "should allow nil user for system records" do
    manufacturer = create(:manufacturer, :system)
    assert_nil manufacturer.user
    assert manufacturer.system_record?
  end

  # System Record Tests
  test "system_record defaults to false" do
    manufacturer = build(:manufacturer)
    assert_equal false, manufacturer.system_record
  end

  test "system records have no user" do
    manufacturer = create(:manufacturer, :system)
    assert manufacturer.system_record?
    assert_nil manufacturer.user_id
  end

  test "user-owned records have user and system_record false" do
    user = create(:user)
    manufacturer = create(:manufacturer, :user_owned, user: user)
    assert_not manufacturer.system_record?
    assert_equal user, manufacturer.user
  end

  # Scope Tests
  test "system scope returns only system records" do
    system_manufacturer = create(:manufacturer, :system, name: "System Mfg")
    user = create(:user)
    user_manufacturer = create(:manufacturer, :user_owned, user: user, name: "User Mfg")

    system_records = Manufacturer.system
    assert_includes system_records, system_manufacturer
    assert_not_includes system_records, user_manufacturer
  end

  test "user_owned scope returns records for specific user" do
    user1 = create(:user)
    user2 = create(:user)
    manufacturer1 = create(:manufacturer, :user_owned, user: user1, name: "User1 Mfg")
    manufacturer2 = create(:manufacturer, :user_owned, user: user2, name: "User2 Mfg")
    system_manufacturer = create(:manufacturer, :system, name: "System Mfg")

    user1_records = Manufacturer.user_owned(user1)
    assert_includes user1_records, manufacturer1
    assert_not_includes user1_records, manufacturer2
    assert_not_includes user1_records, system_manufacturer
  end

  test "visible_to scope returns system records and user's own records" do
    user1 = create(:user)
    user2 = create(:user)
    system_manufacturer = create(:manufacturer, :system, name: "System Mfg")
    user1_manufacturer = create(:manufacturer, :user_owned, user: user1, name: "User1 Mfg")
    user2_manufacturer = create(:manufacturer, :user_owned, user: user2, name: "User2 Mfg")

    visible_to_user1 = Manufacturer.visible_to(user1)
    assert_includes visible_to_user1, system_manufacturer
    assert_includes visible_to_user1, user1_manufacturer
    assert_not_includes visible_to_user1, user2_manufacturer
  end

  # Authorization Method Tests
  test "editable_by? returns false for system records" do
    user = create(:user)
    manufacturer = create(:manufacturer, :system)
    assert_not manufacturer.editable_by?(user)
  end

  test "editable_by? returns true for owner of user-owned record" do
    user = create(:user)
    manufacturer = create(:manufacturer, :user_owned, user: user)
    assert manufacturer.editable_by?(user)
  end

  test "editable_by? returns false for non-owner of user-owned record" do
    owner = create(:user)
    other_user = create(:user)
    manufacturer = create(:manufacturer, :user_owned, user: owner)
    assert_not manufacturer.editable_by?(other_user)
  end

  test "editable_by? returns false when user is nil" do
    manufacturer = create(:manufacturer, :user_owned)
    assert_not manufacturer.editable_by?(nil)
  end

  # Uniqueness Tests
  test "does not allow duplicate name globally" do
    user1 = create(:user)
    user2 = create(:user)
    create(:manufacturer, :user_owned, user: user1, name: "Custom Radio")
    manufacturer2 = build(:manufacturer, :user_owned, user: user2, name: "Custom Radio")
    assert_not manufacturer2.valid?, "Should not allow duplicate names globally"
    assert_includes manufacturer2.errors[:name], "has already been taken"
  end

  test "allows user-owned name that differs from system record name" do
    create(:manufacturer, :system, name: "Motorola")
    user = create(:user)
    manufacturer = build(:manufacturer, :user_owned, user: user, name: "Motorola (Custom)")
    assert manufacturer.valid?, "Should allow user to create custom name similar to system"
  end
end
