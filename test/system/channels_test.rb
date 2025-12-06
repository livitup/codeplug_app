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
end
