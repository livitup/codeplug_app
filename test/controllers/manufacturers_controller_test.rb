require "test_helper"

class ManufacturersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    log_in_as(@user)
    @manufacturer = create(:manufacturer)
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

  # Show Tests
  test "should get show" do
    get manufacturer_path(@manufacturer)
    assert_response :success
  end

  test "show should display manufacturer name" do
    get manufacturer_path(@manufacturer)
    assert_select "h1", @manufacturer.name
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
    assert_redirected_to manufacturer_path(Manufacturer.last)
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
  test "should get edit" do
    get edit_manufacturer_path(@manufacturer)
    assert_response :success
  end

  test "edit should display form with existing value" do
    get edit_manufacturer_path(@manufacturer)
    assert_select "form"
    assert_select "input[value=?]", @manufacturer.name
  end

  # Update Tests
  test "should update manufacturer with valid attributes" do
    patch manufacturer_path(@manufacturer), params: {
      manufacturer: {
        name: "Updated Name"
      }
    }
    assert_redirected_to manufacturer_path(@manufacturer)
    @manufacturer.reload
    assert_equal "Updated Name", @manufacturer.name
  end

  test "should not update manufacturer with invalid attributes" do
    original_name = @manufacturer.name
    patch manufacturer_path(@manufacturer), params: {
      manufacturer: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
    @manufacturer.reload
    assert_equal original_name, @manufacturer.name
  end

  # Destroy Tests
  test "should destroy manufacturer" do
    assert_difference("Manufacturer.count", -1) do
      delete manufacturer_path(@manufacturer)
    end
    assert_redirected_to manufacturers_path
    assert_equal "Manufacturer was successfully deleted.", flash[:notice]
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
