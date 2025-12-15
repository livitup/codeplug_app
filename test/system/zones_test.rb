require "application_system_test_case"

class ZonesTest < ApplicationSystemTestCase
  test "creating a new zone" do
    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")

    visit codeplug_path(codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    click_link "Manage Zones"
    click_link "New Zone"

    fill_in "Name", with: "Zone 1"
    fill_in "Long name", with: "Local Repeaters"
    fill_in "Short name", with: "LCL"
    click_button "Create Zone"

    assert_text "Zone was successfully created"
    assert_text "Zone 1"
    assert_text "Local Repeaters"
    assert_text "LCL"
  end

  test "editing a zone" do
    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")
    zone = create(:zone, codeplug: codeplug, name: "Original Zone")

    visit codeplug_zones_path(codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    click_link "Edit", match: :first

    fill_in "Name", with: "Updated Zone"
    fill_in "Long name", with: "Updated Long Name"
    click_button "Update Zone"

    assert_text "Zone was successfully updated"
    assert_text "Updated Zone"
    assert_text "Updated Long Name"
  end

  test "viewing zones index" do
    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")
    zone1 = create(:zone, codeplug: codeplug, name: "Zone 1", long_name: "Zone One")
    zone2 = create(:zone, codeplug: codeplug, name: "Zone 2", long_name: "Zone Two")

    visit codeplug_zones_path(codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "Zone 1"
    assert_text "Zone 2"
    assert_text "Zone One"
    assert_text "Zone Two"
  end

  test "viewing zone details" do
    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")
    zone = create(:zone, codeplug: codeplug, name: "Test Zone", long_name: "Test Long Name")

    visit codeplug_zone_path(codeplug, zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "Test Zone"
    assert_text "Test Long Name"
  end

  test "empty state shows helpful message" do
    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")

    visit codeplug_zones_path(codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "No zones found"
    assert_link "Create the first one"
  end

  test "manage zones link from codeplug show page" do
    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")

    visit codeplug_path(codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    click_link "Manage Zones"

    assert_current_path codeplug_zones_path(codeplug)
    assert_text "Zones"
  end

  test "cannot access other user's zones" do
    user = create(:user, email: "test@example.com", password: "password123")
    other_user = create(:user)
    other_codeplug = create(:codeplug, user: other_user, name: "Other Codeplug")

    visit codeplug_zones_path(other_codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "You don't have permission to access this codeplug"
    assert_current_path codeplugs_path
  end

  test "zone shows channels with drag handles" do
    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")
    zone = create(:zone, codeplug: codeplug, name: "Test Zone")
    system = create(:system)
    channel1 = create(:channel, codeplug: codeplug, system: system, long_name: "Channel 1")
    channel2 = create(:channel, codeplug: codeplug, system: system, long_name: "Channel 2")
    create(:channel_zone, zone: zone, channel: channel1, position: 1)
    create(:channel_zone, zone: zone, channel: channel2, position: 2)

    visit codeplug_zone_path(codeplug, zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "Channel 1"
    assert_text "Channel 2"
    assert_text "2 channels"

    # Verify drag handles are present (via Bootstrap icon SVG)
    assert_selector ".drag-handle", count: 2
    assert_selector ".list-group-item[data-id]", count: 2
  end

  test "adding a channel to a zone" do
    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")
    zone = create(:zone, codeplug: codeplug, name: "Test Zone")
    system = create(:system)
    channel = create(:channel, codeplug: codeplug, system: system, long_name: "Test Channel")

    visit codeplug_zone_path(codeplug, zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Verify the add channel form is present
    assert_selector "select#channel_zone_channel_id"
    assert_button "Add Channel"

    select "Test Channel", from: "channel_zone_channel_id"
    click_button "Add Channel"

    assert_text "Channel was successfully added to zone"
    assert_text "Test Channel"
    assert_text "1 channel"
  end

  # Skipping due to Turbo confirm dialog issues with Capybara
  # Controller tests cover the functionality
  test "removing a channel from a zone" do
    skip "Turbo confirm dialogs don't work reliably in system tests"

    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")
    zone = create(:zone, codeplug: codeplug, name: "Test Zone")
    system = create(:system)
    channel = create(:channel, codeplug: codeplug, system: system, long_name: "Test Channel")
    create(:channel_zone, zone: zone, channel: channel, position: 1)

    visit codeplug_zone_path(codeplug, zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "Test Channel"
    assert_text "1 channel"

    click_button "Remove"

    assert_text "Channel was successfully removed from zone"
    assert_text "No channels in this zone yet"
  end

  test "editing a channel from zone view" do
    user = create(:user, email: "test@example.com", password: "password123")
    codeplug = create(:codeplug, user: user, name: "Test Codeplug")
    zone = create(:zone, codeplug: codeplug, name: "Test Zone")
    system = create(:system)
    channel = create(:channel, codeplug: codeplug, system: system, long_name: "Original Name")
    create(:channel_zone, zone: zone, channel: channel, position: 1)

    visit codeplug_zone_path(codeplug, zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Click the Edit button within the channel list (not the zone edit button)
    within(".list-group") do
      click_link "Edit"
    end

    assert_text "Edit Channel"
    fill_in "Long name", with: "Updated Name"
    click_button "Update Channel"

    assert_text "Channel was successfully updated"
  end

  # ========================================
  # Standalone Zones Tests (top-level resource)
  # ========================================

  test "user can navigate to standalone zones index from navbar" do
    user = create(:user, email: "test@example.com", password: "password123")
    create(:zone, user: user, name: "My Zone", public: false)

    visit login_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    click_link "Zones", match: :first

    assert_current_path zones_path
    assert_text "Zones"
    assert_text "My Zone"
  end

  test "standalone zones index shows user's zones and public zones" do
    user = create(:user, email: "test@example.com", password: "password123")
    other_user = create(:user, email: "other@example.com")

    # User's zones
    create(:zone, user: user, name: "My Private Zone", public: false)
    create(:zone, user: user, name: "My Public Zone", public: true)

    # Other user's zones
    create(:zone, user: other_user, name: "Other Public Zone", public: true)
    create(:zone, user: other_user, name: "Other Private Zone", public: false)

    visit zones_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Should see own zones (both public and private)
    assert_text "My Private Zone"
    assert_text "My Public Zone"
    # Should see other users' public zones
    assert_text "Other Public Zone"
    # Should NOT see other users' private zones
    assert_no_text "Other Private Zone"
  end

  test "standalone zones index shows owner and visibility badges" do
    user = create(:user, email: "test@example.com", password: "password123")
    other_user = create(:user, email: "other@example.com")

    create(:zone, user: user, name: "My Private Zone", public: false)
    create(:zone, user: other_user, name: "Other Public Zone", public: true)

    visit zones_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Verify the table headers for standalone zones
    assert_selector "th", text: "Owner"
    assert_selector "th", text: "Visibility"
    assert_selector "th", text: "Systems"

    # Verify badges
    assert_selector ".badge.bg-secondary", text: "Private"
    assert_selector ".badge.bg-success", text: "Public"
    assert_text "You"  # Owner column for own zones
    assert_text "other@example.com"  # Owner column for other user's zone
  end

  test "user can view standalone zone details" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "Test Zone", long_name: "Test Long Name", public: false)

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "Test Zone"
    assert_text "Test Long Name"
    assert_text "Zone Details"
    assert_selector ".badge.bg-secondary", text: "Private"
    assert_link "Edit"
    assert_button "Delete"
  end

  test "user can view other user's public zone" do
    user = create(:user, email: "test@example.com", password: "password123")
    other_user = create(:user, email: "other@example.com")
    public_zone = create(:zone, user: other_user, name: "Other Public Zone", public: true)

    visit zone_path(public_zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "Other Public Zone"
    assert_text "other@example.com"  # Owner info shown
    assert_selector ".badge.bg-success", text: "Public"
    # Should not see Edit/Delete buttons for other user's zone
    assert_no_link "Edit"
    assert_no_button "Delete"
  end

  test "user cannot view other user's private zone" do
    user = create(:user, email: "test@example.com", password: "password123")
    other_user = create(:user, email: "other@example.com")
    private_zone = create(:zone, user: other_user, name: "Other Private Zone", public: false)

    visit zone_path(private_zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Should get forbidden (no page content)
    assert_no_text "Other Private Zone"
  end

  test "standalone zone shows systems with drag-drop reordering" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "Test Zone")
    system1 = create(:system, name: "System 1", rx_frequency: 145.0, tx_frequency: 145.6)
    system2 = create(:system, name: "System 2", rx_frequency: 446.0, tx_frequency: 446.0)
    create(:zone_system, zone: zone, system: system1, position: 1)
    create(:zone_system, zone: zone, system: system2, position: 2)

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "System 1"
    assert_text "System 2"
    assert_text "2 systems"
    assert_text "145.0 MHz"
    assert_text "446.0 MHz"

    # Verify drag handles are present for owner
    assert_selector ".drag-handle", count: 2
    assert_selector ".list-group-item[data-id]", count: 2
  end

  test "adding a system to standalone zone" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "Test Zone")
    system = create(:system, name: "Test System", rx_frequency: 145.0, tx_frequency: 145.6)

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Verify the add system form is present
    assert_selector "select#zone_system_system_id"
    assert_button "Add System"

    select "Test System", from: "zone_system_system_id"
    click_button "Add System"

    assert_text "System was successfully added to zone"
    assert_text "Test System"
    assert_text "1 system"
  end

  test "standalone zone empty state shows helpful message" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "Empty Zone")

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "No systems in this zone yet"
  end

  test "creating a new standalone zone" do
    user = create(:user, email: "test@example.com", password: "password123")

    visit new_zone_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    fill_in "Name", with: "New Standalone Zone"
    fill_in "Long name", with: "My New Zone Long Name"
    fill_in "Short name", with: "NSZ"
    click_button "Create Zone"

    assert_text "Zone was successfully created"
    assert_text "New Standalone Zone"
    assert_text "My New Zone Long Name"
  end

  test "editing standalone zone" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "Original Name")

    visit edit_zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    fill_in "Name", with: "Updated Name"
    fill_in "Long name", with: "Updated Long Name"
    click_button "Update Zone"

    assert_text "Zone was successfully updated"
    assert_text "Updated Name"
    assert_text "Updated Long Name"
  end
end
