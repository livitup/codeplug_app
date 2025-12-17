require "application_system_test_case"

class ChannelsTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, email: "test@example.com", password: "password123")
    @codeplug = create(:codeplug, user: @user, name: "Test Codeplug")
  end

  test "talkgroup field is hidden when analog system is selected" do
    analog_system = create(:system, :analog, name: "Analog Repeater")
    dmr_system = create(:system, name: "DMR Repeater", mode: "dmr", color_code: 1)

    visit new_codeplug_channel_path(@codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Initially, with no system selected, talkgroup field should be hidden
    assert_selector "#talkgroup-field", visible: :hidden

    # Select analog system - talkgroup field should remain hidden
    select "Analog Repeater", from: "System"
    assert_selector "#talkgroup-field", visible: :hidden

    # Select DMR system - talkgroup field should become visible
    select "DMR Repeater", from: "System"
    assert_selector "#talkgroup-field", visible: :visible
  end

  test "talkgroup field is visible for digital systems on page load" do
    dmr_system = create(:system, name: "DMR Repeater", mode: "dmr", color_code: 1)
    channel = create(:channel, codeplug: @codeplug, system: dmr_system, name: "DMR Channel")

    visit edit_codeplug_channel_path(@codeplug, channel)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Talkgroup field should be visible for a channel with a digital system
    assert_selector "#talkgroup-field", visible: :visible
  end

  test "talkgroup field is hidden for analog systems on page load" do
    analog_system = create(:system, :analog, name: "Analog Repeater")
    channel = create(:channel, codeplug: @codeplug, system: analog_system, name: "Analog Channel")

    visit edit_codeplug_channel_path(@codeplug, channel)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Talkgroup field should be hidden for a channel with an analog system
    assert_selector "#talkgroup-field", visible: :hidden
  end

  test "talkgroup field visibility toggles when switching between analog and digital systems" do
    analog_system = create(:system, :analog, name: "Analog Repeater")
    p25_system = create(:system, :p25, name: "P25 System")
    nxdn_system = create(:system, :nxdn, name: "NXDN System")

    visit new_codeplug_channel_path(@codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Select P25 system - talkgroup field should be visible
    select "P25 System", from: "System"
    assert_selector "#talkgroup-field", visible: :visible

    # Switch to analog - talkgroup field should hide
    select "Analog Repeater", from: "System"
    assert_selector "#talkgroup-field", visible: :hidden

    # Switch to NXDN - talkgroup field should be visible again
    select "NXDN System", from: "System"
    assert_selector "#talkgroup-field", visible: :visible
  end

  # Talkgroup filtering tests
  test "talkgroup dropdown only shows talkgroups for selected DMR system" do
    # Create two DMR systems with different networks
    network1 = create(:network, name: "Network 1", network_type: "Digital-DMR")
    network2 = create(:network, name: "Network 2", network_type: "Digital-DMR")

    dmr_system1 = create(:system, mode: "dmr", name: "DMR System 1", color_code: 1)
    dmr_system1.networks << network1
    dmr_system2 = create(:system, mode: "dmr", name: "DMR System 2", color_code: 2)
    dmr_system2.networks << network2

    # Create talkgroups on each network
    tg1 = create(:talk_group, name: "TG on Network 1", network: network1)
    tg2 = create(:talk_group, name: "TG on Network 2", network: network2)

    # Create system_talk_groups
    stg1 = create(:system_talk_group, system: dmr_system1, talk_group: tg1, timeslot: 1)
    stg2 = create(:system_talk_group, system: dmr_system2, talk_group: tg2, timeslot: 1)

    visit new_codeplug_channel_path(@codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Select DMR System 1
    select "DMR System 1", from: "System"

    # Should see TG from Network 1, not from Network 2
    assert_selector "option", text: /TG on Network 1/
    assert_no_selector "option", text: /TG on Network 2/

    # Switch to DMR System 2
    select "DMR System 2", from: "System"

    # Should see TG from Network 2, not from Network 1
    assert_selector "option", text: /TG on Network 2/
    assert_no_selector "option", text: /TG on Network 1/
  end

  test "talkgroup dropdown shows P25 talkgroups for P25 system" do
    # Create P25 system and network
    p25_network = create(:network, name: "P25 Network", network_type: "Digital-P25")
    dmr_network = create(:network, name: "DMR Network", network_type: "Digital-DMR")

    p25_system = create(:system, :p25, name: "P25 System")

    # Create talkgroups on each network
    p25_tg = create(:talk_group, name: "P25 TalkGroup", network: p25_network)
    dmr_tg = create(:talk_group, name: "DMR TalkGroup", network: dmr_network)

    # Create system_talk_group for P25 (P25 doesn't require network association on system)
    stg = create(:system_talk_group, system: p25_system, talk_group: p25_tg, timeslot: nil)

    visit new_codeplug_channel_path(@codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Select P25 System
    select "P25 System", from: "System"

    # Should see P25 talkgroup
    assert_selector "option", text: /P25 TalkGroup/
    # Should NOT see DMR talkgroup
    assert_no_selector "option", text: /DMR TalkGroup/
  end

  test "DMR system without network shows no talkgroups" do
    dmr_system = create(:system, mode: "dmr", name: "DMR System No Network", color_code: 1)
    # Don't associate with any network

    visit new_codeplug_channel_path(@codeplug)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Select DMR System
    select "DMR System No Network", from: "System"

    # Talkgroup field should be visible but dropdown should only have prompt
    assert_selector "#talkgroup-field", visible: :visible
    within("#talkgroup-field") do
      # Should only have the prompt option, no talkgroups
      assert_selector "option", count: 2  # prompt + include_blank
    end
  end

  test "editing channel shows correct talkgroups for the system" do
    # Create DMR system with network and talkgroup
    network = create(:network, name: "Test Network", network_type: "Digital-DMR")
    dmr_system = create(:system, mode: "dmr", name: "DMR System", color_code: 1)
    dmr_system.networks << network
    tg = create(:talk_group, name: "Test TG", network: network)
    stg = create(:system_talk_group, system: dmr_system, talk_group: tg, timeslot: 1)

    # Create channel with this system and talkgroup
    channel = create(:channel, codeplug: @codeplug, system: dmr_system, system_talk_group: stg, name: "Test Channel")

    visit edit_codeplug_channel_path(@codeplug, channel)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Should see the talkgroup in dropdown
    assert_selector "option", text: /Test TG/
  end

  # Generated channel customization tests
  test "generated channel shows Generated badge on show page" do
    zone = create(:zone, user: @user, name: "Source Zone")
    analog_system = create(:system, :analog, name: "Test System")
    channel = create(:channel, codeplug: @codeplug, system: analog_system, name: "Generated Channel", source_zone: zone)

    visit codeplug_channel_path(@codeplug, channel)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_selector ".badge", text: "Generated"
    assert_text "Source Zone"
  end

  test "generated channel shows context info on edit page" do
    zone = create(:zone, user: @user, name: "My Source Zone")
    analog_system = create(:system, :analog, name: "Test System")
    channel = create(:channel, codeplug: @codeplug, system: analog_system, name: "Generated Channel", source_zone: zone)

    visit edit_codeplug_channel_path(@codeplug, channel)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_text "Generated Channel"
    assert_text "My Source Zone"
    assert_text "Changes will persist until you regenerate channels"
  end

  test "user can edit generated channel name" do
    zone = create(:zone, user: @user, name: "Source Zone")
    analog_system = create(:system, :analog, name: "Test System")
    channel = create(:channel, codeplug: @codeplug, system: analog_system, name: "Original Name", source_zone: zone)

    visit edit_codeplug_channel_path(@codeplug, channel)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    fill_in "Name", with: "Custom Name"
    click_button "Update Channel"

    assert_text "Channel was successfully updated"
    assert_text "Custom Name"
  end

  test "user can change generated channel power level" do
    zone = create(:zone, user: @user, name: "Source Zone")
    analog_system = create(:system, :analog, name: "Test System")
    channel = create(:channel, codeplug: @codeplug, system: analog_system, name: "Test Channel", source_zone: zone, power_level: "High")

    visit edit_codeplug_channel_path(@codeplug, channel)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    select "Low", from: "Power level"
    click_button "Update Channel"

    assert_text "Channel was successfully updated"
    channel.reload
    assert_equal "Low", channel.power_level
  end

  test "manually created channel does not show Generated badge" do
    analog_system = create(:system, :analog, name: "Test System")
    channel = create(:channel, codeplug: @codeplug, system: analog_system, name: "Manual Channel", source_zone: nil)

    visit codeplug_channel_path(@codeplug, channel)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_no_selector ".badge", text: "Generated"
  end
end
