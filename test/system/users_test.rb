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

  test "unauthenticated user redirected from profile page" do
    user = create(:user, name: "Test User", callsign: "W1ABC")

    visit user_path(user)

    # Should be redirected to login with flash message
    assert_text "You must be logged in to access this page"
    assert_current_path login_path
  end

  test "unauthenticated user redirected from edit profile page" do
    user = create(:user)

    visit edit_user_path(user)

    # Should be redirected to login with flash message
    assert_text "You must be logged in to access this page"
    assert_current_path login_path
  end
end
