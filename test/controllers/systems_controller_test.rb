require "test_helper"

class SystemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    log_in_as(@user)
    @dmr_detail = create(:dmr_mode_detail, color_code: 1)
    @system = create(:system, mode: "dmr", mode_detail: @dmr_detail)
  end

  # Index Tests
  test "should get index" do
    get systems_path
    assert_response :success
  end

  test "index should display systems" do
    get systems_path
    assert_select "h1", "Systems"
  end

  test "index should display system names and frequencies" do
    sys1 = create(:system, name: "W4ABC Repeater", mode: "dmr", mode_detail: @dmr_detail)
    sys2 = create(:system, :analog, name: "Test Repeater")
    get systems_path
    assert_select "td", text: /W4ABC Repeater/
    assert_select "td", text: /Test Repeater/
  end

  # Show Tests
  test "should get show" do
    get system_path(@system)
    assert_response :success
  end

  test "show should display system name" do
    get system_path(@system)
    assert_select "h1", @system.name
  end

  test "show should display system details" do
    sys = create(:system,
      name: "W4ABC Repeater",
      mode: "dmr",
      mode_detail: @dmr_detail,
      tx_frequency: 145.230,
      rx_frequency: 144.630)
    get system_path(sys)
    assert_select "span.badge", text: /DMR/
    assert_select "dd", text: /145\.230/
    assert_select "dd", text: /144\.630/
  end

  # New Tests
  test "should get new" do
    get new_system_path
    assert_response :success
  end

  test "new should display form" do
    get new_system_path
    assert_select "form"
  end

  # Create Tests - DMR
  test "should create DMR system with valid attributes" do
    dmr_detail = create(:dmr_mode_detail, color_code: 2)
    assert_difference("System.count", 1) do
      post systems_path, params: {
        system: {
          name: "Test DMR System",
          mode: "dmr",
          tx_frequency: 145.430,
          rx_frequency: 144.830,
          mode_detail_id: dmr_detail.id,
          mode_detail_type: "DmrModeDetail"
        }
      }
    end
    assert_redirected_to system_path(System.last)
  end

  # Create Tests - Analog
  test "should create analog system with valid attributes" do
    analog_detail = create(:analog_mode_detail)
    assert_difference("System.count", 1) do
      post systems_path, params: {
        system: {
          name: "Test Analog System",
          mode: "analog",
          tx_frequency: 146.940,
          rx_frequency: 146.340,
          mode_detail_id: analog_detail.id,
          mode_detail_type: "AnalogModeDetail"
        }
      }
    end
    assert_redirected_to system_path(System.last)
  end

  # Create Tests - P25
  test "should create P25 system with valid attributes" do
    p25_detail = create(:p25_mode_detail, nac: "293")
    assert_difference("System.count", 1) do
      post systems_path, params: {
        system: {
          name: "Test P25 System",
          mode: "p25",
          tx_frequency: 154.950,
          rx_frequency: 154.950,
          mode_detail_id: p25_detail.id,
          mode_detail_type: "P25ModeDetail"
        }
      }
    end
    assert_redirected_to system_path(System.last)
  end

  test "should not create system with invalid attributes" do
    assert_no_difference("System.count") do
      post systems_path, params: {
        system: {
          name: "",
          mode: "dmr"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit Tests
  test "should get edit" do
    get edit_system_path(@system)
    assert_response :success
  end

  test "edit should display form with existing values" do
    get edit_system_path(@system)
    assert_select "form"
    assert_select "input[value=?]", @system.name
  end

  # Update Tests
  test "should update system with valid attributes" do
    patch system_path(@system), params: {
      system: {
        name: "Updated Name"
      }
    }
    assert_redirected_to system_path(@system)
    @system.reload
    assert_equal "Updated Name", @system.name
  end

  test "should not update system with invalid attributes" do
    original_name = @system.name
    patch system_path(@system), params: {
      system: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
    @system.reload
    assert_equal original_name, @system.name
  end

  # Destroy Tests
  test "should destroy system" do
    assert_difference("System.count", -1) do
      delete system_path(@system)
    end
    assert_redirected_to systems_path
    assert_equal "System was successfully deleted.", flash[:notice]
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
