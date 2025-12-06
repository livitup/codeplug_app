require "test_helper"

class RadioModelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    log_in_as(@user)
    @manufacturer = create(:manufacturer, :system)
    @system_radio_model = create(:radio_model, :system, manufacturer: @manufacturer, name: "System Model")
    @user_radio_model = create(:radio_model, :user_owned, user: @user, manufacturer: @manufacturer, name: "User Model")
    @other_user_radio_model = create(:radio_model, :user_owned, user: @other_user, manufacturer: @manufacturer, name: "Other User Model")
  end

  # Index Tests
  test "should get index" do
    get radio_models_path
    assert_response :success
    assert_select "h1", /Radio Models/i
  end

  test "index shows system records and own records only" do
    get radio_models_path
    assert_select "td", text: "System Model"
    assert_select "td", text: "User Model"
    assert_select "td", { text: "Other User Model", count: 0 }
  end

  # Show Tests
  test "should show system radio model" do
    get radio_model_path(@system_radio_model)
    assert_response :success
    assert_select "h1", text: /#{@system_radio_model.name}/
  end

  test "should show own radio model" do
    get radio_model_path(@user_radio_model)
    assert_response :success
    assert_select "h1", text: /#{@user_radio_model.name}/
  end

  test "should not show other user's radio model" do
    get radio_model_path(@other_user_radio_model)
    assert_response :forbidden
  end

  test "should display manufacturer on show page" do
    get radio_model_path(@user_radio_model)
    assert_response :success
    assert_select "dt", text: /Manufacturer/i
    assert_select "dd", text: @manufacturer.name
  end

  test "should display supported modes on show page" do
    get radio_model_path(@user_radio_model)
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
    radio_model = RadioModel.last
    assert_equal @user, radio_model.user
    assert_not radio_model.system_record?
    assert_redirected_to radio_model_path(radio_model)
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
  test "should get edit for own record" do
    get edit_radio_model_path(@user_radio_model)
    assert_response :success
    assert_select "h1", /Edit Radio Model/i
    assert_select "form[action=?]", radio_model_path(@user_radio_model)
  end

  test "should not get edit for system record" do
    get edit_radio_model_path(@system_radio_model)
    assert_response :forbidden
  end

  test "should not get edit for other user's record" do
    get edit_radio_model_path(@other_user_radio_model)
    assert_response :forbidden
  end

  # Update Tests
  test "should update own radio model with valid data" do
    patch radio_model_path(@user_radio_model), params: {
      radio_model: {
        name: "Updated Name",
        max_zones: 200
      }
    }
    assert_redirected_to radio_model_path(@user_radio_model)
    assert_equal "Radio model was successfully updated.", flash[:notice]

    @user_radio_model.reload
    assert_equal "Updated Name", @user_radio_model.name
    assert_equal 200, @user_radio_model.max_zones
  end

  test "should not update radio model with invalid data" do
    patch radio_model_path(@user_radio_model), params: {
      radio_model: { name: "" }
    }
    assert_response :unprocessable_entity

    @user_radio_model.reload
    assert_not_equal "", @user_radio_model.name
  end

  test "should not update system radio model" do
    original_name = @system_radio_model.name
    patch radio_model_path(@system_radio_model), params: {
      radio_model: { name: "Hacked Name" }
    }
    assert_response :forbidden
    @system_radio_model.reload
    assert_equal original_name, @system_radio_model.name
  end

  test "should not update other user's radio model" do
    original_name = @other_user_radio_model.name
    patch radio_model_path(@other_user_radio_model), params: {
      radio_model: { name: "Hacked Name" }
    }
    assert_response :forbidden
    @other_user_radio_model.reload
    assert_equal original_name, @other_user_radio_model.name
  end

  # Destroy Tests
  test "should destroy own radio model" do
    assert_difference("RadioModel.count", -1) do
      delete radio_model_path(@user_radio_model)
    end
    assert_redirected_to radio_models_path
    assert_equal "Radio model was successfully deleted.", flash[:notice]
  end

  test "should not destroy system radio model" do
    assert_no_difference("RadioModel.count") do
      delete radio_model_path(@system_radio_model)
    end
    assert_response :forbidden
  end

  test "should not destroy other user's radio model" do
    assert_no_difference("RadioModel.count") do
      delete radio_model_path(@other_user_radio_model)
    end
    assert_response :forbidden
  end
end
