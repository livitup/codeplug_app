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
end
