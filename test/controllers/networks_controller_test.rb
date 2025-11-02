require "test_helper"

class NetworksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    log_in_as(@user)
    @network = create(:network)
  end

  # Index Tests
  test "should get index" do
    get networks_path
    assert_response :success
  end

  test "index should display networks" do
    get networks_path
    assert_select "h1", "Networks"
  end

  test "index should display network names" do
    network1 = create(:network, name: "Brandmeister")
    network2 = create(:network, name: "DMRVA")
    get networks_path
    assert_select "td", network1.name
    assert_select "td", network2.name
  end

  # Show Tests
  test "should get show" do
    get network_path(@network)
    assert_response :success
  end

  test "show should display network name" do
    get network_path(@network)
    assert_select "h1", @network.name
  end

  test "show should display network details" do
    network = create(:network,
      name: "Brandmeister",
      description: "Worldwide DMR network",
      website: "https://brandmeister.network",
      network_type: "Digital-DMR")
    get network_path(network)
    assert_select "dd", "Worldwide DMR network"
    assert_select "a[href='https://brandmeister.network']", "https://brandmeister.network"
    assert_select "dd", "Digital-DMR"
  end

  # New Tests
  test "should get new" do
    get new_network_path
    assert_response :success
  end

  test "new should display form" do
    get new_network_path
    assert_select "form"
  end

  # Create Tests
  test "should create network with valid attributes" do
    assert_difference("Network.count", 1) do
      post networks_path, params: {
        network: {
          name: "Test Network",
          network_type: "Digital-DMR"
        }
      }
    end
    assert_redirected_to network_path(Network.last)
  end

  test "should create network with all attributes" do
    assert_difference("Network.count", 1) do
      post networks_path, params: {
        network: {
          name: "Full Network",
          description: "A complete network",
          website: "https://example.com",
          network_type: "Digital-P25"
        }
      }
    end
    network = Network.last
    assert_equal "Full Network", network.name
    assert_equal "A complete network", network.description
    assert_equal "https://example.com", network.website
    assert_equal "Digital-P25", network.network_type
  end

  test "should not create network with invalid attributes" do
    assert_no_difference("Network.count") do
      post networks_path, params: {
        network: {
          name: ""
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create network with duplicate name" do
    create(:network, name: "Duplicate Network")
    assert_no_difference("Network.count") do
      post networks_path, params: {
        network: {
          name: "Duplicate Network"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit Tests
  test "should get edit" do
    get edit_network_path(@network)
    assert_response :success
  end

  test "edit should display form with existing value" do
    get edit_network_path(@network)
    assert_select "form"
    assert_select "input[value=?]", @network.name
  end

  # Update Tests
  test "should update network with valid attributes" do
    patch network_path(@network), params: {
      network: {
        name: "Updated Name"
      }
    }
    assert_redirected_to network_path(@network)
    @network.reload
    assert_equal "Updated Name", @network.name
  end

  test "should update network with all attributes" do
    patch network_path(@network), params: {
      network: {
        name: "Updated Network",
        description: "Updated description",
        website: "https://updated.com",
        network_type: "Analog"
      }
    }
    assert_redirected_to network_path(@network)
    @network.reload
    assert_equal "Updated Network", @network.name
    assert_equal "Updated description", @network.description
    assert_equal "https://updated.com", @network.website
    assert_equal "Analog", @network.network_type
  end

  test "should not update network with invalid attributes" do
    original_name = @network.name
    patch network_path(@network), params: {
      network: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
    @network.reload
    assert_equal original_name, @network.name
  end

  # Destroy Tests
  test "should destroy network" do
    assert_difference("Network.count", -1) do
      delete network_path(@network)
    end
    assert_redirected_to networks_path
    assert_equal "Network was successfully deleted.", flash[:notice]
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
