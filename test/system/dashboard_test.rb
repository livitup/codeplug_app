require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
  test "non-logged-in user sees landing page" do
    visit root_path

    assert_text "Welcome to Codeplug App"
    assert_text "Your universal solution for managing two-way radio programming data"
    assert_link "Sign Up"
    assert_link "Log In"
    assert_no_text "Dashboard"
  end

  test "logged-in user sees dashboard instead of landing page" do
    user = create(:user, email: "dashboard1@example.com", password: "password123")

    visit login_path
    fill_in "Email", with: "dashboard1@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    assert_text "Dashboard"
    assert_no_text "Welcome to Codeplug App"
  end

  test "dashboard shows user stats" do
    user = create(:user, email: "dashboard2@example.com", password: "password123")

    # Create some data for the user
    create_list(:codeplug, 3, user: user)
    create_list(:zone, 2, user: user, public: false)
    create_list(:zone, 1, user: user, public: true)

    visit login_path
    fill_in "Email", with: "dashboard2@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    # Should show codeplugs count
    assert_selector ".display-4", text: "3"
    assert_text "Codeplugs"

    # Should show zones count
    assert_text "Zones"
  end

  test "dashboard shows quick action links" do
    user = create(:user, email: "dashboard3@example.com", password: "password123")

    visit login_path
    fill_in "Email", with: "dashboard3@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    assert_link "New Codeplug"
    assert_link "New Zone"
  end

  test "dashboard shows recent codeplugs" do
    user = create(:user, email: "dashboard4@example.com", password: "password123")

    # Create codeplugs with specific names
    create(:codeplug, user: user, name: "Codeplug Alpha", created_at: 5.days.ago)
    create(:codeplug, user: user, name: "Codeplug Beta", created_at: 3.days.ago)
    create(:codeplug, user: user, name: "Codeplug Gamma", created_at: 1.day.ago)

    visit login_path
    fill_in "Email", with: "dashboard4@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    assert_text "Recent Codeplugs"
    assert_text "Codeplug Alpha"
    assert_text "Codeplug Beta"
    assert_text "Codeplug Gamma"
  end

  test "dashboard shows recent zones" do
    user = create(:user, email: "dashboard5@example.com", password: "password123")

    # Create zones with specific names
    create(:zone, user: user, name: "Zone Alpha", created_at: 5.days.ago)
    create(:zone, user: user, name: "Zone Beta", created_at: 3.days.ago)
    create(:zone, user: user, name: "Zone Gamma", created_at: 1.day.ago)

    visit login_path
    fill_in "Email", with: "dashboard5@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    assert_text "Recent Zones"
    assert_text "Zone Alpha"
    assert_text "Zone Beta"
    assert_text "Zone Gamma"
  end

  test "dashboard recent codeplugs are clickable" do
    user = create(:user, email: "dashboard6@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "My Clickable Codeplug")

    visit login_path
    fill_in "Email", with: "dashboard6@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    click_link "My Clickable Codeplug"

    assert_current_path codeplug_path(codeplug)
  end

  test "dashboard recent zones are clickable" do
    user = create(:user, email: "dashboard7@example.com", password: "password123")
    zone = create(:zone, user: user, name: "My Clickable Zone")

    visit login_path
    fill_in "Email", with: "dashboard7@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    click_link "My Clickable Zone"

    assert_current_path zone_path(zone)
  end

  test "dashboard limits recent items to 5" do
    user = create(:user, email: "dashboard8@example.com", password: "password123")

    # Create 7 codeplugs
    7.times do |i|
      create(:codeplug, user: user, name: "Codeplug #{i + 1}", created_at: (7 - i).days.ago)
    end

    visit login_path
    fill_in "Email", with: "dashboard8@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    # Should show the 5 most recent (Codeplug 3-7)
    assert_text "Codeplug 7"
    assert_text "Codeplug 6"
    assert_text "Codeplug 5"
    assert_text "Codeplug 4"
    assert_text "Codeplug 3"

    # Should NOT show the oldest two
    assert_no_text "Codeplug 1"
    assert_no_text "Codeplug 2"
  end

  test "dashboard shows empty state for new user" do
    user = create(:user, email: "dashboard9@example.com", password: "password123")

    visit login_path
    fill_in "Email", with: "dashboard9@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    assert_selector ".display-4", text: "0"
    assert_text "Codeplugs"
    assert_text "Zones"
  end

  test "dashboard shows public zones count" do
    user = create(:user, email: "dashboard10@example.com", password: "password123")
    other_user = create(:user)

    # Create public zones from other users
    create_list(:zone, 3, user: other_user, public: true)

    visit login_path
    fill_in "Email", with: "dashboard10@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    # Should show count of public zones available
    assert_text "Public Zones"
    assert_selector ".display-4", text: "3"
  end

  test "dashboard quick links navigate correctly" do
    user = create(:user, email: "dashboard11@example.com", password: "password123")

    visit login_path
    fill_in "Email", with: "dashboard11@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"
    assert_text "Logged in successfully"

    visit root_path

    click_link "New Codeplug"
    assert_current_path new_codeplug_path

    visit root_path

    click_link "New Zone"
    assert_current_path new_zone_path
  end
end
