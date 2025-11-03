require "test_helper"

class SystemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    log_in_as(@user)
    @system = create(:system)
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
    sys1 = create(:system, name: "W4ABC Repeater")
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
      color_code: 1,
      tx_frequency: 145.230,
      rx_frequency: 144.630)
    get system_path(sys)
    assert_select "span.badge", text: /DMR/
    assert_select "dd", text: /145\.230/
    assert_select "dd", text: /144\.630/
  end

  test "show should display associated networks" do
    dmr_network = create(:network, name: "Brandmeister", network_type: "Digital-DMR")
    sys = create(:system, mode: "dmr", color_code: 1)
    sys.networks << dmr_network

    get system_path(sys)
    assert_select "dt", text: /Networks/
    assert_select "a.badge", text: /Brandmeister/
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
    assert_difference("System.count", 1) do
      post systems_path, params: {
        system: {
          name: "Test DMR System",
          mode: "dmr",
          tx_frequency: 145.430,
          rx_frequency: 144.830,
          color_code: 2
        }
      }
    end
    assert_redirected_to system_path(System.last)
  end

  # Create Tests - Analog
  test "should create analog system with valid attributes" do
    assert_difference("System.count", 1) do
      post systems_path, params: {
        system: {
          name: "Test Analog System",
          mode: "analog",
          tx_frequency: 146.940,
          rx_frequency: 146.340
        }
      }
    end
    assert_redirected_to system_path(System.last)
  end

  # Create Tests - P25
  test "should create P25 system with valid attributes" do
    assert_difference("System.count", 1) do
      post systems_path, params: {
        system: {
          name: "Test P25 System",
          mode: "p25",
          tx_frequency: 154.950,
          rx_frequency: 154.950,
          nac: "$293"
        }
      }
    end
    assert_redirected_to system_path(System.last)
  end

  # Network Association Tests
  test "should create DMR system with network associations" do
    dmr_network1 = create(:network, name: "Brandmeister", network_type: "Digital-DMR")
    dmr_network2 = create(:network, name: "DMRVA", network_type: "Digital-DMR")

    assert_difference("System.count", 1) do
      assert_difference("SystemNetwork.count", 2) do
        post systems_path, params: {
          system: {
            name: "Test DMR System with Networks",
            mode: "dmr",
            tx_frequency: 145.430,
            rx_frequency: 144.830,
            color_code: 1,
            network_ids: [ dmr_network1.id, dmr_network2.id ]
          }
        }
      end
    end

    assert_redirected_to system_path(System.last)
    assert_equal 2, System.last.networks.count
    assert_includes System.last.networks, dmr_network1
    assert_includes System.last.networks, dmr_network2
  end

  test "should create P25 system with network associations" do
    p25_network = create(:network, :p25_network)

    assert_difference("System.count", 1) do
      assert_difference("SystemNetwork.count", 1) do
        post systems_path, params: {
          system: {
            name: "Test P25 System with Network",
            mode: "p25",
            tx_frequency: 154.950,
            rx_frequency: 154.950,
            nac: "$293",
            network_ids: [ p25_network.id ]
          }
        }
      end
    end

    assert_redirected_to system_path(System.last)
    assert_equal 1, System.last.networks.count
    assert_equal p25_network, System.last.networks.first
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
