require "test_helper"

class ManufacturersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    log_in_as(@user)
    @system_manufacturer = create(:manufacturer, :system, name: "System Manufacturer")
    @user_manufacturer = create(:manufacturer, :user_owned, user: @user, name: "User Manufacturer")
    @other_user_manufacturer = create(:manufacturer, :user_owned, user: @other_user, name: "Other User Manufacturer")
  end

  # Index Tests
  test "should get index" do
    get manufacturers_path
    assert_response :success
  end

  test "index should display manufacturers" do
    get manufacturers_path
    assert_select "h1", "Manufacturers"
  end

  test "index shows system records and own records only" do
    get manufacturers_path
    assert_select "td", text: "System Manufacturer"
    assert_select "td", text: "User Manufacturer"
    assert_select "td", { text: "Other User Manufacturer", count: 0 }
  end

  # Show Tests
  test "should get show for system record" do
    get manufacturer_path(@system_manufacturer)
    assert_response :success
  end

  test "should get show for own record" do
    get manufacturer_path(@user_manufacturer)
    assert_response :success
  end

  test "should not show other user's record" do
    get manufacturer_path(@other_user_manufacturer)
    assert_response :forbidden
  end

  test "show should display manufacturer name" do
    get manufacturer_path(@user_manufacturer)
    assert_select "h1", text: /#{@user_manufacturer.name}/
  end

  # New Tests
  test "should get new" do
    get new_manufacturer_path
    assert_response :success
  end

  test "new should display form" do
    get new_manufacturer_path
    assert_select "form"
  end

  # Create Tests
  test "should create manufacturer with valid attributes" do
    assert_difference("Manufacturer.count", 1) do
      post manufacturers_path, params: {
        manufacturer: {
          name: "Test Manufacturer"
        }
      }
    end
    manufacturer = Manufacturer.last
    assert_equal @user, manufacturer.user
    assert_not manufacturer.system_record?
    assert_redirected_to manufacturer_path(manufacturer)
  end

  test "should not create manufacturer with invalid attributes" do
    assert_no_difference("Manufacturer.count") do
      post manufacturers_path, params: {
        manufacturer: {
          name: ""
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit Tests
  test "should get edit for own record" do
    get edit_manufacturer_path(@user_manufacturer)
    assert_response :success
  end

  test "should not get edit for system record" do
    get edit_manufacturer_path(@system_manufacturer)
    assert_response :forbidden
  end

  test "should not get edit for other user's record" do
    get edit_manufacturer_path(@other_user_manufacturer)
    assert_response :forbidden
  end

  test "edit should display form with existing value" do
    get edit_manufacturer_path(@user_manufacturer)
    assert_select "form"
    assert_select "input[value=?]", @user_manufacturer.name
  end

  # Update Tests
  test "should update own manufacturer with valid attributes" do
    patch manufacturer_path(@user_manufacturer), params: {
      manufacturer: {
        name: "Updated Name"
      }
    }
    assert_redirected_to manufacturer_path(@user_manufacturer)
    @user_manufacturer.reload
    assert_equal "Updated Name", @user_manufacturer.name
  end

  test "should not update manufacturer with invalid attributes" do
    original_name = @user_manufacturer.name
    patch manufacturer_path(@user_manufacturer), params: {
      manufacturer: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
    @user_manufacturer.reload
    assert_equal original_name, @user_manufacturer.name
  end

  test "should not update system manufacturer" do
    original_name = @system_manufacturer.name
    patch manufacturer_path(@system_manufacturer), params: {
      manufacturer: {
        name: "Hacked Name"
      }
    }
    assert_response :forbidden
    @system_manufacturer.reload
    assert_equal original_name, @system_manufacturer.name
  end

  test "should not update other user's manufacturer" do
    original_name = @other_user_manufacturer.name
    patch manufacturer_path(@other_user_manufacturer), params: {
      manufacturer: {
        name: "Hacked Name"
      }
    }
    assert_response :forbidden
    @other_user_manufacturer.reload
    assert_equal original_name, @other_user_manufacturer.name
  end

  # Destroy Tests
  test "should destroy own manufacturer" do
    assert_difference("Manufacturer.count", -1) do
      delete manufacturer_path(@user_manufacturer)
    end
    assert_redirected_to manufacturers_path
    assert_equal "Manufacturer was successfully deleted.", flash[:notice]
  end

  test "should not destroy system manufacturer" do
    assert_no_difference("Manufacturer.count") do
      delete manufacturer_path(@system_manufacturer)
    end
    assert_response :forbidden
  end

  test "should not destroy other user's manufacturer" do
    assert_no_difference("Manufacturer.count") do
      delete manufacturer_path(@other_user_manufacturer)
    end
    assert_response :forbidden
  end

  private

  def log_in_as(user)
    post login_path, params: {
      email: user.email,
      password: "password123"
    }
  end
end
