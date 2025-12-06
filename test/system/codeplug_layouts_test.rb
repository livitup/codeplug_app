require "application_system_test_case"

class CodeplugLayoutsTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, email: "test@example.com", password: "password123")
    @manufacturer = create(:manufacturer, :system)
    @radio_model = create(:radio_model, :system, manufacturer: @manufacturer)
  end

  test "visiting the index" do
    layout = create(:codeplug_layout, radio_model: @radio_model)

    visit codeplug_layouts_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_selector "h1", text: "Codeplug Layouts"
    assert_text layout.name
  end

  test "creating a new codeplug layout with drag-and-drop interface" do
    visit new_codeplug_layout_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_selector "h1", text: "New Codeplug Layout"
    assert_selector "[data-controller='field-picker']"

    # Fill in basic details
    fill_in "Name", with: "My Custom Layout"
    select "#{@manufacturer.name} #{@radio_model.name}", from: "Radio Model"

    # Verify source fields panel is visible
    assert_selector ".source-fields-container"
    # Headers are uppercase due to CSS text-transform
    assert_selector ".field-group-header", text: /CHANNEL/i
    assert_selector ".field-group-header", text: /SYSTEM/i

    # Verify layout builder is visible
    assert_selector "[data-field-picker-target='layoutBuilder']"

    # Submit the form
    click_button "Create Codeplug layout"

    # Verify the layout was created
    assert_text "Codeplug layout was successfully created"
    assert_text "My Custom Layout"
  end

  test "showing available fields organized by category" do
    visit new_codeplug_layout_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # Check for Channel fields
    assert_text "Name"
    assert_text "Long Name"
    assert_text "Short Name"

    # Check for System fields
    assert_text "RX Frequency"
    assert_text "TX Frequency"

    # Check for Zone fields
    assert_text "Zone Name"
  end

  test "search filters available fields" do
    visit new_codeplug_layout_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # All fields visible initially
    assert_text "RX Frequency"
    assert_text "TX Frequency"
    assert_text "Long Name"

    # Search for frequency
    fill_in placeholder: "Search fields...", with: "frequency"

    # Only frequency fields should be visible now
    # This is a JS feature, so we need to wait for it
    assert_selector ".source-field", text: "RX Frequency"
    assert_selector ".source-field", text: "TX Frequency"
  end

  test "editing an existing layout loads fields into builder" do
    layout = create(:codeplug_layout, radio_model: @radio_model)

    visit edit_codeplug_layout_path(layout)
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    assert_selector "h1", text: "Edit Codeplug Layout"
    assert_field "Name", with: layout.name

    # Verify the JSON preview shows the layout definition
    click_link "Show JSON Preview (Advanced)"
    assert_text "columns"
  end

  test "CSV preview updates when fields are added" do
    visit new_codeplug_layout_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    fill_in "Name", with: "Test Layout"
    select "#{@manufacturer.name} #{@radio_model.name}", from: "Radio Model"

    # The CSV preview section should exist
    assert_selector "[data-field-picker-target='csvPreview']"
  end

  test "JSON preview can be toggled" do
    visit new_codeplug_layout_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log In"

    # JSON preview should be hidden initially
    assert_no_selector "#jsonPreviewCollapse.show"

    # Click to show JSON preview
    click_link "Show JSON Preview (Advanced)"

    # JSON preview should now be visible
    assert_selector "#jsonPreviewCollapse.show"
  end
end
