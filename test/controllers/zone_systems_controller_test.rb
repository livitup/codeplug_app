require "test_helper"

class ZoneSystemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    @zone = create(:zone, user: @user, name: "Test Zone")
    @other_zone = create(:zone, user: @other_user, name: "Other Zone")
    @system1 = create(:system, name: "System 1")
    @system2 = create(:system, name: "System 2")
    @system3 = create(:system, name: "System 3")
  end

  # Create Action Tests
  test "should add system to zone" do
    log_in_as(@user)

    assert_difference("ZoneSystem.count", 1) do
      post zone_zone_systems_path(@zone), params: {
        zone_system: {
          system_id: @system1.id
        }
      }
    end

    assert_redirected_to zone_path(@zone)
    assert_equal "System was successfully added to zone.", flash[:notice]

    zone_system = ZoneSystem.last
    assert_equal @zone, zone_system.zone
    assert_equal @system1, zone_system.system
    assert_equal 1, zone_system.position
  end

  test "should auto-assign next position when adding system" do
    log_in_as(@user)

    # Add first system
    create(:zone_system, zone: @zone, system: @system1, position: 1)

    # Add second system
    post zone_zone_systems_path(@zone), params: {
      zone_system: {
        system_id: @system2.id
      }
    }

    zone_system = ZoneSystem.last
    assert_equal 2, zone_system.position
  end

  test "should not add duplicate system to zone" do
    log_in_as(@user)
    create(:zone_system, zone: @zone, system: @system1, position: 1)

    assert_no_difference("ZoneSystem.count") do
      post zone_zone_systems_path(@zone), params: {
        zone_system: {
          system_id: @system1.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not add system to other user's zone" do
    log_in_as(@user)

    assert_no_difference("ZoneSystem.count") do
      post zone_zone_systems_path(@other_zone), params: {
        zone_system: {
          system_id: @system1.id
        }
      }
    end

    assert_response :forbidden
  end

  test "should require login for create" do
    assert_no_difference("ZoneSystem.count") do
      post zone_zone_systems_path(@zone), params: {
        zone_system: {
          system_id: @system1.id
        }
      }
    end

    assert_redirected_to login_path
  end

  # Destroy Action Tests
  test "should remove system from zone" do
    log_in_as(@user)
    zone_system = create(:zone_system, zone: @zone, system: @system1, position: 1)

    assert_difference("ZoneSystem.count", -1) do
      delete zone_zone_system_path(@zone, zone_system)
    end

    assert_redirected_to zone_path(@zone)
    assert_equal "System was successfully removed from zone.", flash[:notice]
  end

  test "should reorder positions after removing system" do
    log_in_as(@user)
    zs1 = create(:zone_system, zone: @zone, system: @system1, position: 1)
    zs2 = create(:zone_system, zone: @zone, system: @system2, position: 2)
    zs3 = create(:zone_system, zone: @zone, system: @system3, position: 3)

    # Remove middle system
    delete zone_zone_system_path(@zone, zs2)

    # Verify positions are reordered
    assert_equal 1, zs1.reload.position
    assert_equal 2, zs3.reload.position
  end

  test "should not remove system from other user's zone" do
    log_in_as(@user)
    zone_system = create(:zone_system, zone: @other_zone, system: @system1, position: 1)

    assert_no_difference("ZoneSystem.count") do
      delete zone_zone_system_path(@other_zone, zone_system)
    end

    assert_response :forbidden
  end

  test "should require login for destroy" do
    zone_system = create(:zone_system, zone: @zone, system: @system1, position: 1)

    assert_no_difference("ZoneSystem.count") do
      delete zone_zone_system_path(@zone, zone_system)
    end

    assert_redirected_to login_path
  end

  # Update Positions Action Tests
  test "should update system positions" do
    log_in_as(@user)
    zs1 = create(:zone_system, zone: @zone, system: @system1, position: 1)
    zs2 = create(:zone_system, zone: @zone, system: @system2, position: 2)
    zs3 = create(:zone_system, zone: @zone, system: @system3, position: 3)

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
    zs = create(:zone_system, zone: @other_zone, system: @system1, position: 1)

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
