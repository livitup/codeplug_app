require "application_system_test_case"

class SystemTalkGroupsTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, email: "test@example.com", password: "password123")
    @dmr_network = create(:network, name: "Brandmeister", network_type: "Digital-DMR")
    @p25_network = create(:network, name: "P25 Net", network_type: "Digital-P25")
  end

  # Analog Systems - No TalkGroups section
  test "analog system does not show talkgroups section" do
    analog_system = create(:system, :analog, name: "Analog Repeater")

    visit system_path(analog_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "Analog Repeater"
    assert_text "ANALOG"
    # Check that the talkgroups section card doesn't exist
    assert_no_selector "#talkgroups-section"
    assert_no_text "Add TalkGroup"
  end

  # DMR Systems without network - Show helpful message
  test "DMR system without network shows helpful message" do
    dmr_system = create(:system, mode: "dmr", name: "DMR Repeater", color_code: 1)
    # Don't associate with any network

    visit system_path(dmr_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "TalkGroups"
    assert_text "Associate this system with a DMR network to add talkgroups"
    assert_link "Edit System"
  end

  # DMR Systems with network - Show only talkgroups from associated networks
  test "DMR system with network shows only talkgroups from that network" do
    dmr_system = create(:system, mode: "dmr", name: "DMR Repeater", color_code: 1)
    dmr_system.networks << @dmr_network

    # Create talkgroups on different networks
    associated_tg = create(:talk_group, name: "Virginia", network: @dmr_network)
    other_network = create(:network, name: "Other DMR", network_type: "Digital-DMR")
    other_tg = create(:talk_group, name: "Other TG", network: other_network)

    visit system_path(dmr_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Should see the associated talkgroup in dropdown
    assert_selector "option", text: "Virginia"
    # Should NOT see the other network's talkgroup
    assert_no_selector "option", text: "Other TG"
  end

  # P25 Systems - Show only P25 talkgroups
  test "P25 system shows only P25 talkgroups" do
    p25_system = create(:system, :p25, name: "P25 System")

    # Create talkgroups on different networks
    p25_tg = create(:talk_group, name: "P25 TalkGroup", network: @p25_network)
    dmr_tg = create(:talk_group, name: "DMR TalkGroup", network: @dmr_network)

    visit system_path(p25_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Should see P25 talkgroup in dropdown
    assert_selector "option", text: "P25 TalkGroup"
    # Should NOT see DMR talkgroup
    assert_no_selector "option", text: "DMR TalkGroup"
  end

  # Basic functionality tests
  test "visiting a system shows empty talkgroups section" do
    dmr_system = create(:system, mode: "dmr", name: "Test DMR System", color_code: 1)
    dmr_system.networks << @dmr_network

    visit system_path(dmr_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "TalkGroups"
    assert_text "No talkgroups associated with this system yet"
    assert_text "Add TalkGroup"
  end

  test "adding a talkgroup with timeslot to a system" do
    dmr_system = create(:system, mode: "dmr", name: "Test DMR System", color_code: 1)
    dmr_system.networks << @dmr_network
    talk_group = create(:talk_group, name: "Virginia", network: @dmr_network)

    visit system_path(dmr_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Add a talkgroup with timeslot 1
    select "Virginia", from: "TalkGroup"
    select "Timeslot 1", from: "Timeslot"
    click_button "Add TalkGroup"

    # Verify the talkgroup appears
    assert_text "Virginia"
    assert_text "TS1"
    assert_no_text "No talkgroups associated with this system yet"
  end

  test "adding a talkgroup to P25 system without timeslot" do
    p25_system = create(:system, :p25, name: "Test P25 System")
    talk_group = create(:talk_group, name: "P25 TG", network: @p25_network)

    visit system_path(p25_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Add a talkgroup without timeslot (P25 doesn't require timeslot)
    select "P25 TG", from: "TalkGroup"
    select "None", from: "Timeslot"
    click_button "Add TalkGroup"

    # Verify the talkgroup appears without timeslot badge
    assert_text "P25 TG"
    assert_no_text "TS"
  end

  test "adding same talkgroup on different timeslots" do
    dmr_system = create(:system, mode: "dmr", name: "Test DMR System", color_code: 1)
    dmr_system.networks << @dmr_network
    talk_group = create(:talk_group, name: "Virginia", network: @dmr_network)

    visit system_path(dmr_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Add talkgroup on timeslot 1
    select "Virginia", from: "TalkGroup"
    select "Timeslot 1", from: "Timeslot"
    click_button "Add TalkGroup"

    assert_text "TS1"

    # Add same talkgroup on timeslot 2
    select "Virginia", from: "TalkGroup"
    select "Timeslot 2", from: "Timeslot"
    click_button "Add TalkGroup"

    # Should see both timeslots
    assert_text "TS1"
    assert_text "TS2"
  end

  test "removing a talkgroup from a system" do
    dmr_system = create(:system, mode: "dmr", name: "Test DMR System", color_code: 1)
    dmr_system.networks << @dmr_network
    talk_group = create(:talk_group, name: "Virginia", network: @dmr_network)
    create(:system_talk_group, system: dmr_system, talk_group: talk_group, timeslot: 1)

    visit system_path(dmr_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Verify talkgroup is present
    assert_text "Virginia"
    assert_text "TS1"

    # Remove the talkgroup
    accept_confirm do
      click_button "Remove"
    end

    # Verify it's gone from the list (not checking dropdown)
    within "#system_talk_groups" do
      assert_text "No talkgroups associated with this system yet"
      assert_no_text "TS1"
    end
  end

  test "displaying multiple talkgroups" do
    dmr_system = create(:system, mode: "dmr", name: "Test DMR System", color_code: 1)
    dmr_system.networks << @dmr_network
    talk_group = create(:talk_group, name: "Virginia", network: @dmr_network)
    another_talk_group = create(:talk_group, name: "Worldwide", network: @dmr_network)
    create(:system_talk_group, system: dmr_system, talk_group: talk_group, timeslot: 1)
    create(:system_talk_group, system: dmr_system, talk_group: another_talk_group, timeslot: 2)

    visit system_path(dmr_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Verify both talkgroups are displayed
    assert_text "Virginia"
    assert_text "Worldwide"
    assert_text "TS1"
    assert_text "TS2"
  end

  test "talkgroup links to talkgroup show page" do
    dmr_system = create(:system, mode: "dmr", name: "Test DMR System", color_code: 1)
    dmr_system.networks << @dmr_network
    talk_group = create(:talk_group, name: "Virginia", network: @dmr_network)
    create(:system_talk_group, system: dmr_system, talk_group: talk_group, timeslot: 1)

    visit system_path(dmr_system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Click on the talkgroup name
    click_link "Virginia"

    # Should navigate to talkgroup show page
    assert_current_path talk_group_path(talk_group)
    assert_text "Virginia"
  end
end
