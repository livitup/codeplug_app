require "test_helper"

class CodeplugLayoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    log_in_as(@user)
    @radio_model = create(:radio_model)
    @codeplug_layout = create(:codeplug_layout, radio_model: @radio_model)
  end

  # Index Tests
  test "should get index" do
    get codeplug_layouts_path
    assert_response :success
  end

  test "index should display codeplug layouts" do
    get codeplug_layouts_path
    assert_select "h1", "Codeplug Layouts"
  end

  test "index should list layouts with radio model" do
    get codeplug_layouts_path
    assert_select "td", @codeplug_layout.name
    assert_select "td", @codeplug_layout.radio_model.name
  end

  # Show Tests
  test "should get show" do
    get codeplug_layout_path(@codeplug_layout)
    assert_response :success
  end

  test "show should display layout name and details" do
    get codeplug_layout_path(@codeplug_layout)
    assert_select "h1", @codeplug_layout.name
  end

  test "show should display JSON layout definition" do
    get codeplug_layout_path(@codeplug_layout)
    assert_response :success
    # Should show the layout definition in some form
    assert_match /layout/i, response.body.downcase
  end

  # New Tests
  test "should get new" do
    get new_codeplug_layout_path
    assert_response :success
  end

  test "new should display form" do
    get new_codeplug_layout_path
    assert_select "form"
  end

  test "new should have radio model select" do
    get new_codeplug_layout_path
    assert_select "select#codeplug_layout_radio_model_id"
  end

  # Create Tests
  test "should create codeplug layout with valid attributes" do
    layout_def = {
      "columns" => [
        { "header" => "Channel Name", "maps_to" => "long_name" }
      ]
    }

    assert_difference("CodeplugLayout.count", 1) do
      post codeplug_layouts_path, params: {
        codeplug_layout: {
          name: "Test Layout",
          radio_model_id: @radio_model.id,
          layout_definition: layout_def.to_json
        }
      }
    end
    assert_redirected_to codeplug_layout_path(CodeplugLayout.last)
  end

  test "should not create codeplug layout without name" do
    assert_no_difference("CodeplugLayout.count") do
      post codeplug_layouts_path, params: {
        codeplug_layout: {
          name: "",
          radio_model_id: @radio_model.id,
          layout_definition: { "columns" => [] }.to_json
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create codeplug layout without radio_model" do
    assert_no_difference("CodeplugLayout.count") do
      post codeplug_layouts_path, params: {
        codeplug_layout: {
          name: "Test Layout",
          radio_model_id: nil,
          layout_definition: { "columns" => [] }.to_json
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create codeplug layout without layout_definition" do
    assert_no_difference("CodeplugLayout.count") do
      post codeplug_layouts_path, params: {
        codeplug_layout: {
          name: "Test Layout",
          radio_model_id: @radio_model.id,
          layout_definition: ""
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit Tests
  test "should get edit" do
    get edit_codeplug_layout_path(@codeplug_layout)
    assert_response :success
  end

  test "edit should display form with existing values" do
    get edit_codeplug_layout_path(@codeplug_layout)
    assert_select "form"
    assert_select "input[value=?]", @codeplug_layout.name
  end

  # Update Tests
  test "should update codeplug layout with valid attributes" do
    patch codeplug_layout_path(@codeplug_layout), params: {
      codeplug_layout: {
        name: "Updated Layout Name"
      }
    }
    assert_redirected_to codeplug_layout_path(@codeplug_layout)
    @codeplug_layout.reload
    assert_equal "Updated Layout Name", @codeplug_layout.name
  end

  test "should not update codeplug layout with invalid attributes" do
    original_name = @codeplug_layout.name
    patch codeplug_layout_path(@codeplug_layout), params: {
      codeplug_layout: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
    @codeplug_layout.reload
    assert_equal original_name, @codeplug_layout.name
  end

  # Destroy Tests
  test "should destroy codeplug layout" do
    assert_difference("CodeplugLayout.count", -1) do
      delete codeplug_layout_path(@codeplug_layout)
    end
    assert_redirected_to codeplug_layouts_path
    assert_equal "Codeplug layout was successfully deleted.", flash[:notice]
  end

  private

  # Helper method to simulate user login
  def log_in_as(user)
    post login_path, params: {
      email: user.email,
      password: "password123"
    }
  end
end
