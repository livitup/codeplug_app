require "test_helper"

class ZonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    @zone = create(:zone, user: @user, name: "Zone 1")
    @other_zone = create(:zone, user: @other_user, name: "Other Zone")
  end

  # Index Action Tests
  test "should show user's zones and public zones" do
    log_in_as(@user)

    # Create test data
    my_public_zone = create(:zone, user: @user, public: true, name: "My Public Zone")
    my_private_zone = create(:zone, user: @user, public: false, name: "My Private Zone")
    other_public_zone = create(:zone, user: @other_user, public: true, name: "Other Public Zone")
    other_private_zone = create(:zone, user: @other_user, public: false, name: "Other Private Zone")

    get zones_path

    assert_response :success
    # Should see own zones (both public and private)
    assert_select "body", text: /My Public Zone/
    assert_select "body", text: /My Private Zone/
    # Should see other users' public zones
    assert_select "body", text: /Other Public Zone/
    # Should NOT see other users' private zones
    assert_select "body", { text: /Other Private Zone/, count: 0 }
  end

  test "should require login for index" do
    get zones_path
    assert_redirected_to login_path
  end

  # Show Action Tests
  test "should display public zone to any user" do
    log_in_as(@user)
    public_zone = create(:zone, user: @other_user, public: true, name: "Public Zone")

    get zone_path(public_zone)

    assert_response :success
    assert_select "h1", "Public Zone"
  end

  test "should display own private zone" do
    log_in_as(@user)
    my_private_zone = create(:zone, user: @user, public: false, name: "My Private Zone")

    get zone_path(my_private_zone)

    assert_response :success
    assert_select "h1", "My Private Zone"
  end

  test "should not display other user's private zone" do
    log_in_as(@user)
    other_private_zone = create(:zone, user: @other_user, public: false, name: "Private Zone")

    get zone_path(other_private_zone)

    assert_response :forbidden
  end

  test "should require login for show" do
    public_zone = create(:zone, user: @user, public: true)

    get zone_path(public_zone)

    assert_redirected_to login_path
  end

  # New Action Tests
  test "should get new" do
    log_in_as(@user)
    get new_zone_path

    assert_response :success
    assert_select "h1", "New Zone"
  end

  test "should require login for new" do
    get new_zone_path
    assert_redirected_to login_path
  end

  # Create Action Tests
  test "should create zone for logged in user" do
    log_in_as(@user)

    assert_difference("Zone.count", 1) do
      post zones_path, params: {
        zone: {
          name: "New Zone",
          long_name: "New Long Zone Name",
          short_name: "NZN",
          public: false
        }
      }
    end

    zone = Zone.last
    assert_equal @user, zone.user
    assert_equal "New Zone", zone.name
    assert_redirected_to zone_path(zone)
    assert_equal "Zone was successfully created.", flash[:notice]
  end

  test "should not create zone without name" do
    log_in_as(@user)

    assert_no_difference("Zone.count") do
      post zones_path, params: {
        zone: {
          name: "",
          long_name: "Test"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should require login for create" do
    assert_no_difference("Zone.count") do
      post zones_path, params: {
        zone: {
          name: "Test"
        }
      }
    end

    assert_redirected_to login_path
  end

  # Edit Action Tests
  test "should get edit for own zone" do
    log_in_as(@user)
    get edit_zone_path(@zone)

    assert_response :success
    assert_select "h1", text: /Edit Zone/
  end

  test "should not get edit for other user's zone" do
    log_in_as(@user)
    get edit_zone_path(@other_zone)

    assert_response :forbidden
  end

  test "should require login for edit" do
    get edit_zone_path(@zone)
    assert_redirected_to login_path
  end

  # Update Action Tests
  test "should update own zone" do
    log_in_as(@user)

    patch zone_path(@zone), params: {
      zone: {
        name: "Updated Zone",
        long_name: "Updated Long Name"
      }
    }

    @zone.reload
    assert_equal "Updated Zone", @zone.name
    assert_equal "Updated Long Name", @zone.long_name
    assert_redirected_to zone_path(@zone)
    assert_equal "Zone was successfully updated.", flash[:notice]
  end

  test "should not update without name" do
    log_in_as(@user)

    patch zone_path(@zone), params: {
      zone: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
  end

  test "should not update other user's zone" do
    log_in_as(@user)
    original_name = @other_zone.name

    patch zone_path(@other_zone), params: {
      zone: {
        name: "Hacked Name"
      }
    }

    @other_zone.reload
    assert_equal original_name, @other_zone.name
    assert_response :forbidden
  end

  test "should require login for update" do
    patch zone_path(@zone), params: {
      zone: {
        name: "New Name"
      }
    }

    assert_redirected_to login_path
  end

  # Destroy Action Tests
  test "should destroy own zone" do
    log_in_as(@user)

    assert_difference("Zone.count", -1) do
      delete zone_path(@zone)
    end

    assert_redirected_to zones_path
    assert_equal "Zone was successfully deleted.", flash[:notice]
  end

  test "should not destroy other user's zone" do
    log_in_as(@user)

    assert_no_difference("Zone.count") do
      delete zone_path(@other_zone)
    end

    assert_response :forbidden
  end

  test "should require login for destroy" do
    assert_no_difference("Zone.count") do
      delete zone_path(@zone)
    end

    assert_redirected_to login_path
  end

  # Update Positions Action Tests (for zone_systems reordering)
  test "should update zone_system positions for own zone" do
    log_in_as(@user)
    system1 = create(:system, :analog, name: "System 1")
    system2 = create(:system, :analog, name: "System 2")
    system3 = create(:system, :analog, name: "System 3")

    zs1 = create(:zone_system, zone: @zone, system: system1, position: 1)
    zs2 = create(:zone_system, zone: @zone, system: system2, position: 2)
    zs3 = create(:zone_system, zone: @zone, system: system3, position: 3)

    # Reorder: move system3 to position 1
    patch update_positions_zone_path(@zone), params: {
      positions: [
        { id: zs3.id, position: 1 },
        { id: zs1.id, position: 2 },
        { id: zs2.id, position: 3 }
      ]
    }, as: :json

    assert_response :success

    # Verify positions updated
    assert_equal 1, zs3.reload.position
    assert_equal 2, zs1.reload.position
    assert_equal 3, zs2.reload.position
  end

  test "should not update positions for other user's zone" do
    log_in_as(@user)
    system = create(:system, :analog)
    zs = create(:zone_system, zone: @other_zone, system: system, position: 1)

    patch update_positions_zone_path(@other_zone), params: {
      positions: [
        { id: zs.id, position: 2 }
      ]
    }, as: :json

    assert_response :forbidden
  end

  test "should require login for update_positions" do
    patch update_positions_zone_path(@zone), params: {
      positions: []
    }, as: :json

    assert_redirected_to login_path
  end
end
