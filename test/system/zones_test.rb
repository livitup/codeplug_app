require "application_system_test_case"

class ZonesTest < ApplicationSystemTestCase
  test "user can navigate to zones index from navbar" do
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

  test "zones index shows user's zones and public zones" do
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

  test "zones index shows owner and visibility badges" do
    user = create(:user, email: "test@example.com", password: "password123")
    other_user = create(:user, email: "other@example.com")

    create(:zone, user: user, name: "My Private Zone", public: false)
    create(:zone, user: other_user, name: "Other Public Zone", public: true)

    visit zones_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Verify the table headers
    assert_selector "th", text: "Owner"
    assert_selector "th", text: "Visibility"
    assert_selector "th", text: "Systems"

    # Verify badges
    assert_selector ".badge.bg-secondary", text: "Private"
    assert_selector ".badge.bg-success", text: "Public"
    assert_text "You"  # Owner column for own zones
    assert_text "other@example.com"  # Owner column for other user's zone
  end

  test "user can view zone details" do
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

  test "zone shows systems with drag-drop reordering" do
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

  test "adding a system to zone" do
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

  test "zone empty state shows helpful message" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "Empty Zone")

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "No systems in this zone yet"
  end

  test "creating a new zone" do
    user = create(:user, email: "test@example.com", password: "password123")

    visit new_zone_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    fill_in "Name", with: "New Zone"
    fill_in "Long name", with: "My New Zone Long Name"
    fill_in "Short name", with: "NZ"
    click_button "Create Zone"

    assert_text "Zone was successfully created"
    assert_text "New Zone"
    assert_text "My New Zone Long Name"
  end

  test "editing zone" do
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

  test "zones index empty state shows helpful message" do
    user = create(:user, email: "test@example.com", password: "password123")

    visit zones_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "No zones found"
    assert_link "Create the first one"
  end

  # Talkgroup selection tests for digital systems
  test "digital system in zone shows talkgroup management" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "DMR Zone")

    # Create DMR system with network
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_system = create(:system, mode: "dmr", color_code: 1, name: "DMR Repeater")
    dmr_system.networks << dmr_network

    # Create talkgroups
    tg1 = create(:talk_group, name: "Local", talkgroup_number: "3100", network: dmr_network)
    tg2 = create(:talk_group, name: "TAC 1", talkgroup_number: "8951", network: dmr_network)
    create(:system_talk_group, system: dmr_system, talk_group: tg1, timeslot: 1)
    create(:system_talk_group, system: dmr_system, talk_group: tg2, timeslot: 2)

    # Add system to zone
    create(:zone_system, zone: zone, system: dmr_system, position: 1)

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "DMR Repeater"
    assert_selector ".badge", text: "DMR"
    # Should show "Add Talkgroup" option for digital systems
    assert_text "Talkgroups"
    assert_button "Add Talkgroup"
  end

  test "user can add talkgroup to digital system in zone" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "DMR Zone")

    # Create DMR system with network
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_system = create(:system, mode: "dmr", color_code: 1, name: "DMR Repeater")
    dmr_system.networks << dmr_network

    # Create talkgroup
    tg = create(:talk_group, name: "Local", talkgroup_number: "3100", network: dmr_network)
    create(:system_talk_group, system: dmr_system, talk_group: tg, timeslot: 1)

    # Add system to zone
    create(:zone_system, zone: zone, system: dmr_system, position: 1)

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Verify the form is present
    assert_text "None selected"
    assert_button "Add Talkgroup"

    # Select and add talkgroup using the select element
    select "Local (3100) - TS1", from: "zone_system_talk_group[system_talk_group_id]"
    click_button "Add Talkgroup"

    assert_text "Talkgroup was successfully added"
    assert_selector ".badge.bg-primary", text: "TS1"
  end

  test "user can remove talkgroup from digital system in zone" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "DMR Zone")

    # Create DMR system with network
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_system = create(:system, mode: "dmr", color_code: 1, name: "DMR Repeater")
    dmr_system.networks << dmr_network

    # Create talkgroup
    tg = create(:talk_group, name: "Local", talkgroup_number: "3100", network: dmr_network)
    stg = create(:system_talk_group, system: dmr_system, talk_group: tg, timeslot: 1)

    # Add system and talkgroup to zone
    zone_system = create(:zone_system, zone: zone, system: dmr_system, position: 1)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: stg)

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Verify talkgroup is displayed
    assert_text "Local"
    assert_selector ".badge", text: "TS1"

    # Remove talkgroup by clicking the X button within the talkgroup badge
    within(".badge.bg-light") do
      accept_confirm do
        find("button.text-danger").click
      end
    end

    assert_text "Talkgroup was successfully removed"
  end

  test "talkgroup displays show timeslot correctly" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "DMR Zone")

    # Create DMR system with network
    dmr_network = create(:network, network_type: "Digital-DMR")
    dmr_system = create(:system, mode: "dmr", color_code: 1, name: "DMR Repeater")
    dmr_system.networks << dmr_network

    # Create talkgroups with different timeslots
    tg1 = create(:talk_group, name: "Local", talkgroup_number: "3100", network: dmr_network)
    tg2 = create(:talk_group, name: "TAC 1", talkgroup_number: "8951", network: dmr_network)
    stg1 = create(:system_talk_group, system: dmr_system, talk_group: tg1, timeslot: 1)
    stg2 = create(:system_talk_group, system: dmr_system, talk_group: tg2, timeslot: 2)

    # Add system and talkgroups to zone
    zone_system = create(:zone_system, zone: zone, system: dmr_system, position: 1)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: stg1)
    create(:zone_system_talk_group, zone_system: zone_system, system_talk_group: stg2)

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Verify both talkgroups display with correct timeslots
    assert_text "Local"
    assert_text "TAC 1"
    assert_selector ".badge", text: "TS1"
    assert_selector ".badge", text: "TS2"
  end

  test "analog system in zone does not show talkgroup options" do
    user = create(:user, email: "test@example.com", password: "password123")
    zone = create(:zone, user: user, name: "Analog Zone")

    # Create analog system
    analog_system = create(:system, mode: "analog", name: "Analog Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    visit zone_path(zone)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "Analog Repeater"
    assert_selector ".badge", text: "ANALOG"
    # Should NOT show talkgroup options for analog systems
    assert_no_button "Add Talkgroup"
  end
end
