require "test_helper"

class RadioModelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @manufacturer = create(:manufacturer)
    @radio_model = create(:radio_model, manufacturer: @manufacturer)
  end

  # Index Tests
  test "should get index" do
    get radio_models_path
    assert_response :success
    assert_select "h1", /Radio Models/i
  end

  test "should display radio models on index" do
    get radio_models_path
    assert_response :success
    assert_select "td", text: @radio_model.name
    assert_select "td", text: @manufacturer.name
  end

  # Show Tests
  test "should show radio model" do
    get radio_model_path(@radio_model)
    assert_response :success
    assert_select "h1", text: @radio_model.name
  end

  test "should display manufacturer on show page" do
    get radio_model_path(@radio_model)
    assert_response :success
    assert_select "dt", text: /Manufacturer/i
    assert_select "dd", text: @manufacturer.name
  end

  test "should display supported modes on show page" do
    get radio_model_path(@radio_model)
    assert_response :success
    assert_select "dt", text: /Supported Modes/i
  end

  # New Tests
  test "should get new" do
    get new_radio_model_path
    assert_response :success
    assert_select "h1", /New Radio Model/i
    assert_select "form[action=?]", radio_models_path
  end

  test "should have manufacturer select on new form" do
    get new_radio_model_path
    assert_response :success
    assert_select "select[name='radio_model[manufacturer_id]']"
  end

  # Create Tests
  test "should create radio model with valid data" do
    assert_difference("RadioModel.count", 1) do
      post radio_models_path, params: {
        radio_model: {
          manufacturer_id: @manufacturer.id,
          name: "New Model",
          supported_modes: [ "analog", "dmr" ],
          max_zones: 100,
          max_channels_per_zone: 16,
          long_channel_name_length: 16,
          short_channel_name_length: 8,
          long_zone_name_length: 16,
          short_zone_name_length: 8
        }
      }
    end
    assert_redirected_to radio_model_path(RadioModel.last)
    assert_equal "Radio model was successfully created.", flash[:notice]
  end

  test "should not create radio model without name" do
    assert_no_difference("RadioModel.count") do
      post radio_models_path, params: {
        radio_model: {
          manufacturer_id: @manufacturer.id,
          supported_modes: [ "analog" ]
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create radio model without manufacturer" do
    assert_no_difference("RadioModel.count") do
      post radio_models_path, params: {
        radio_model: {
          name: "Test Model",
          supported_modes: [ "analog" ]
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit Tests
  test "should get edit" do
    get edit_radio_model_path(@radio_model)
    assert_response :success
    assert_select "h1", /Edit Radio Model/i
    assert_select "form[action=?]", radio_model_path(@radio_model)
  end

  # Update Tests
  test "should update radio model with valid data" do
    patch radio_model_path(@radio_model), params: {
      radio_model: {
        name: "Updated Name",
        max_zones: 200
      }
    }
    assert_redirected_to radio_model_path(@radio_model)
    assert_equal "Radio model was successfully updated.", flash[:notice]

    @radio_model.reload
    assert_equal "Updated Name", @radio_model.name
    assert_equal 200, @radio_model.max_zones
  end

  test "should not update radio model with invalid data" do
    patch radio_model_path(@radio_model), params: {
      radio_model: { name: "" }
    }
    assert_response :unprocessable_entity

    @radio_model.reload
    assert_not_equal "", @radio_model.name
  end

  # Destroy Tests
  test "should destroy radio model" do
    assert_difference("RadioModel.count", -1) do
      delete radio_model_path(@radio_model)
    end
    assert_redirected_to radio_models_path
    assert_equal "Radio model was successfully deleted.", flash[:notice]
  end
end
