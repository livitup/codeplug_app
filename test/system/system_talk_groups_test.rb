require "application_system_test_case"

class SystemTalkGroupsTest < ApplicationSystemTestCase
  test "visiting a system shows empty talkgroups section" do
    user = create(:user, email: "test@example.com", password: "password123")
    system = create(:system, mode: "dmr", name: "Test DMR System")

    # Visit system page (will redirect to login)
    visit system_path(system)

    # Fill in login form
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Should be back at system page after login
    assert_text "TalkGroups"
    assert_text "No talkgroups associated with this system yet"
    assert_text "Add TalkGroup"
  end

  test "adding a talkgroup with timeslot to a system" do
    user = create(:user, email: "test@example.com", password: "password123")
    system = create(:system, mode: "dmr", name: "Test DMR System")
    talk_group = create(:talk_group, name: "Virginia")

    visit system_path(system)
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

  test "adding a talkgroup without timeslot" do
    user = create(:user, email: "test@example.com", password: "password123")
    system = create(:system, mode: "dmr", name: "Test DMR System")
    talk_group = create(:talk_group, name: "Virginia")

    visit system_path(system)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Add a talkgroup without timeslot
    select "Virginia", from: "TalkGroup"
    select "None", from: "Timeslot"
    click_button "Add TalkGroup"

    # Verify the talkgroup appears without timeslot badge
    assert_text "Virginia"
    assert_no_text "TS"
  end

  test "adding same talkgroup on different timeslots" do
    user = create(:user, email: "test@example.com", password: "password123")
    system = create(:system, mode: "dmr", name: "Test DMR System")
    talk_group = create(:talk_group, name: "Virginia")

    visit system_path(system)
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
    user = create(:user, email: "test@example.com", password: "password123")
    system = create(:system, mode: "dmr", name: "Test DMR System")
    talk_group = create(:talk_group, name: "Virginia")
    create(:system_talk_group, system: system, talk_group: talk_group, timeslot: 1)

    visit system_path(system)
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
    user = create(:user, email: "test@example.com", password: "password123")
    system = create(:system, mode: "dmr", name: "Test DMR System")
    talk_group = create(:talk_group, name: "Virginia")
    another_talk_group = create(:talk_group, name: "Worldwide")
    create(:system_talk_group, system: system, talk_group: talk_group, timeslot: 1)
    create(:system_talk_group, system: system, talk_group: another_talk_group, timeslot: 2)

    visit system_path(system)
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
    user = create(:user, email: "test@example.com", password: "password123")
    system = create(:system, mode: "dmr", name: "Test DMR System")
    talk_group = create(:talk_group, name: "Virginia")
    create(:system_talk_group, system: system, talk_group: talk_group, timeslot: 1)

    visit system_path(system)
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
