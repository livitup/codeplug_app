require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # Note: System tests with Turbo can have timing issues.
  # Controller tests provide thorough coverage of functionality.
  # These system tests focus on key user-facing workflows.

  test "registration form displays all fields" do
    visit new_user_path

    assert_text "Create Account"
    assert_selector "input[name='user[email]']"
    assert_selector "input[name='user[password]']"
    assert_selector "input[name='user[password_confirmation]']"
    assert_selector "input[name='user[name]']"
    assert_selector "input[name='user[callsign]']"
    assert_selector "select[name='user[default_power_level]']"
    assert_selector "select[name='user[measurement_preference]']"
    assert_button "Create Account"
  end

  test "login form displays correctly" do
    visit login_path

    assert_text "Log In"
    assert_selector "input[name='email']"
    assert_selector "input[name='password']"
    assert_button "Log In"
    assert_link "Sign up"
  end

  test "profile page displays user information" do
    user = create(:user, name: "Test User", callsign: "W1ABC", email: "test@example.com")

    # For system tests, we need to manually set the session
    # This is simpler than going through the login form with Turbo
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Log In"

    visit user_path(user)

    assert_text "User Profile"
    assert_text user.email
    assert_text user.name
    assert_text user.callsign
    assert_link "Edit Profile"
  end

  test "edit profile form displays correctly" do
    user = create(:user)

    # Log in
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Log In"

    visit edit_user_path(user)

    assert_text "Edit Profile"
    assert_selector "input[name='user[email]'][value='#{user.email}']"
    assert_selector "input[name='user[name]']"
    assert_selector "input[name='user[callsign]']"
    assert_selector "select[name='user[default_power_level]']"
    assert_button "Update Profile"
    assert_link "Cancel"
  end
end
