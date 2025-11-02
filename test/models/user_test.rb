require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without email" do
    user = build(:user, email: nil)
    assert_not user.save, "Saved user without email"
  end

  test "should not save user with duplicate email" do
    create(:user, email: "test@example.com")
    user2 = build(:user, email: "test@example.com")
    assert_not user2.save, "Saved user with duplicate email"
  end

  test "should save user with valid email and password" do
    user = build(:user)
    assert user.save, "Failed to save valid user"
  end

  test "should authenticate user with correct password" do
    user = create(:user, password: "password123", password_confirmation: "password123")
    assert user.authenticate("password123"), "Failed to authenticate with correct password"
  end

  test "should not authenticate user with incorrect password" do
    user = create(:user, password: "password123", password_confirmation: "password123")
    assert_not user.authenticate("wrongpassword"), "Authenticated with incorrect password"
  end

  test "should have many codeplugs association" do
    user = build(:user)
    assert_respond_to user, :codeplugs, "User should respond to :codeplugs"
  end

  test "email should be case insensitive for uniqueness" do
    create(:user, email: "TEST@EXAMPLE.COM")
    user2 = build(:user, email: "test@example.com")
    assert_not user2.save, "Saved user with duplicate email (case insensitive)"
  end

  test "should save email in lowercase" do
    user = create(:user, email: "UPPER@EXAMPLE.COM")
    assert_equal "upper@example.com", user.email, "Email should be stored in lowercase"
  end

  test "should accept optional name field" do
    user = create(:user, name: "John Doe")
    assert_equal "John Doe", user.name
  end

  test "should accept optional callsign field" do
    user = create(:user, callsign: "W4ABC")
    assert_equal "W4ABC", user.callsign
  end

  test "should accept optional default_power_level field" do
    user = create(:user, default_power_level: "High")
    assert_equal "High", user.default_power_level
  end

  test "should accept optional measurement_preference field" do
    user = create(:user, measurement_preference: "metric")
    assert_equal "metric", user.measurement_preference
  end
end
