require "application_system_test_case"

class NavbarTest < ApplicationSystemTestCase
  test "navbar displays app name" do
    visit root_path

    assert_selector "nav.navbar", text: "Codeplug App"
  end

  test "navbar displays login link when not authenticated" do
    visit root_path

    within "nav.navbar" do
      assert_link "Log In"
      assert_no_link "Log Out"
    end
  end

  test "navbar displays logout button when authenticated" do
    user = create(:user, email: "test@example.com", password: "password123")

    visit login_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    within "nav.navbar" do
      # User dropdown should be visible
      assert_selector "a.dropdown-toggle", text: user.email

      # Click to open user dropdown
      find("a.dropdown-toggle", text: user.email).click

      # Log Out button should be in dropdown
      assert_button "Log Out"
      assert_no_link "Log In"
    end
  end

  test "navbar hides Hardware dropdown when not authenticated" do
    visit root_path

    within "nav.navbar" do
      assert_no_selector "a.dropdown-toggle", text: "Hardware"
    end
  end

  test "navbar shows Hardware dropdown when authenticated" do
    user = create(:user, email: "test@example.com", password: "password123")

    visit login_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    within "nav.navbar" do
      # Find the Hardware dropdown
      assert_selector "a.dropdown-toggle", text: "Hardware"

      # Click to open dropdown
      find("a.dropdown-toggle", text: "Hardware").click

      # Check for dropdown items
      assert_link "Radio Models"
    end
  end

  test "navbar Hardware dropdown links work" do
    user = create(:user, email: "test@example.com", password: "password123")

    # Log in first since radio_models requires authentication
    visit login_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    within "nav.navbar" do
      find("a.dropdown-toggle", text: "Hardware").click
      click_link "Radio Models"
    end

    assert_current_path radio_models_path
  end

  test "navbar is sticky and remains visible when scrolling" do
    visit root_path

    # Check that navbar has sticky/fixed positioning
    navbar = find("nav.navbar")
    assert navbar[:class].include?("fixed-top") || navbar[:class].include?("sticky-top"),
           "Navbar should have fixed-top or sticky-top class"
  end
end
