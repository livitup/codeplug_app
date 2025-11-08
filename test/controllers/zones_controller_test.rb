require "test_helper"

class ZonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    @codeplug = create(:codeplug, user: @user)
    @other_codeplug = create(:codeplug, user: @other_user)
    @zone = create(:zone, codeplug: @codeplug, name: "Zone 1")
    @other_zone = create(:zone, codeplug: @other_codeplug, name: "Other Zone")
  end

  # Index Action Tests
  test "should get index for own codeplug" do
    log_in_as(@user)
    get codeplug_zones_path(@codeplug)

    assert_response :success
    assert_select "h1", "Zones"
  end

  test "should not get index for other user's codeplug" do
    log_in_as(@user)
    get codeplug_zones_path(@other_codeplug)

    assert_redirected_to codeplugs_path
    assert_equal "You don't have permission to access this codeplug.", flash[:alert]
  end

  test "should require login for index" do
    get codeplug_zones_path(@codeplug)
    assert_redirected_to login_path
  end

  # Show Action Tests
  test "should show zone for own codeplug" do
    log_in_as(@user)
    get codeplug_zone_path(@codeplug, @zone)

    assert_response :success
    assert_select "h1", @zone.name
  end

  test "should not show zone from other user's codeplug" do
    log_in_as(@user)
    get codeplug_zone_path(@other_codeplug, @other_zone)

    assert_redirected_to codeplugs_path
  end

  test "should require login for show" do
    get codeplug_zone_path(@codeplug, @zone)
    assert_redirected_to login_path
  end

  # New Action Tests
  test "should get new for own codeplug" do
    log_in_as(@user)
    get new_codeplug_zone_path(@codeplug)

    assert_response :success
    assert_select "h1", "New Zone"
  end

  test "should not get new for other user's codeplug" do
    log_in_as(@user)
    get new_codeplug_zone_path(@other_codeplug)

    assert_redirected_to codeplugs_path
  end

  test "should require login for new" do
    get new_codeplug_zone_path(@codeplug)
    assert_redirected_to login_path
  end

  # Create Action Tests
  test "should create zone for own codeplug" do
    log_in_as(@user)

    assert_difference("Zone.count", 1) do
      post codeplug_zones_path(@codeplug), params: {
        zone: {
          name: "New Zone",
          long_name: "New Long Zone Name",
          short_name: "NZN"
        }
      }
    end

    zone = Zone.last
    assert_equal @codeplug, zone.codeplug
    assert_redirected_to codeplug_zone_path(@codeplug, zone)
    assert_equal "Zone was successfully created.", flash[:notice]
  end

  test "should not create zone without name" do
    log_in_as(@user)

    assert_no_difference("Zone.count") do
      post codeplug_zones_path(@codeplug), params: {
        zone: {
          name: "",
          long_name: "Test"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create zone for other user's codeplug" do
    log_in_as(@user)

    assert_no_difference("Zone.count") do
      post codeplug_zones_path(@other_codeplug), params: {
        zone: {
          name: "Hacked Zone"
        }
      }
    end

    assert_redirected_to codeplugs_path
  end

  test "should require login for create" do
    assert_no_difference("Zone.count") do
      post codeplug_zones_path(@codeplug), params: {
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
    get edit_codeplug_zone_path(@codeplug, @zone)

    assert_response :success
    assert_select "h1", text: /Edit Zone/
  end

  test "should not get edit for other user's zone" do
    log_in_as(@user)
    get edit_codeplug_zone_path(@other_codeplug, @other_zone)

    assert_redirected_to codeplugs_path
  end

  test "should require login for edit" do
    get edit_codeplug_zone_path(@codeplug, @zone)
    assert_redirected_to login_path
  end

  # Update Action Tests
  test "should update own zone" do
    log_in_as(@user)

    patch codeplug_zone_path(@codeplug, @zone), params: {
      zone: {
        name: "Updated Zone",
        long_name: "Updated Long Name"
      }
    }

    @zone.reload
    assert_equal "Updated Zone", @zone.name
    assert_equal "Updated Long Name", @zone.long_name
    assert_redirected_to codeplug_zone_path(@codeplug, @zone)
    assert_equal "Zone was successfully updated.", flash[:notice]
  end

  test "should not update without name" do
    log_in_as(@user)

    patch codeplug_zone_path(@codeplug, @zone), params: {
      zone: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
  end

  test "should not update other user's zone" do
    log_in_as(@user)
    original_name = @other_zone.name

    patch codeplug_zone_path(@other_codeplug, @other_zone), params: {
      zone: {
        name: "Hacked Name"
      }
    }

    @other_zone.reload
    assert_equal original_name, @other_zone.name
    assert_redirected_to codeplugs_path
  end

  test "should require login for update" do
    patch codeplug_zone_path(@codeplug, @zone), params: {
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
      delete codeplug_zone_path(@codeplug, @zone)
    end

    assert_redirected_to codeplug_zones_path(@codeplug)
    assert_equal "Zone was successfully deleted.", flash[:notice]
  end

  test "should not destroy other user's zone" do
    log_in_as(@user)

    assert_no_difference("Zone.count") do
      delete codeplug_zone_path(@other_codeplug, @other_zone)
    end

    assert_redirected_to codeplugs_path
  end

  test "should require login for destroy" do
    assert_no_difference("Zone.count") do
      delete codeplug_zone_path(@codeplug, @zone)
    end

    assert_redirected_to login_path
  end

  # Update Positions Action Tests
  test "should update channel positions for own zone" do
    log_in_as(@user)
    system = create(:system)
    channel1 = create(:channel, codeplug: @codeplug, system: system, long_name: "Channel 1")
    channel2 = create(:channel, codeplug: @codeplug, system: system, long_name: "Channel 2")
    channel3 = create(:channel, codeplug: @codeplug, system: system, long_name: "Channel 3")

    cz1 = create(:channel_zone, zone: @zone, channel: channel1, position: 1)
    cz2 = create(:channel_zone, zone: @zone, channel: channel2, position: 2)
    cz3 = create(:channel_zone, zone: @zone, channel: channel3, position: 3)

    # Reorder: move channel3 to position 1
    patch update_positions_codeplug_zone_path(@codeplug, @zone), params: {
      positions: [
        { id: cz3.id, position: 1 },
        { id: cz1.id, position: 2 },
        { id: cz2.id, position: 3 }
      ]
    }, as: :json

    assert_response :success

    # Verify positions updated
    assert_equal 1, cz3.reload.position
    assert_equal 2, cz1.reload.position
    assert_equal 3, cz2.reload.position
  end

  test "should not update positions for other user's zone" do
    log_in_as(@user)
    system = create(:system)
    channel = create(:channel, codeplug: @other_codeplug, system: system)
    cz = create(:channel_zone, zone: @other_zone, channel: channel, position: 1)

    patch update_positions_codeplug_zone_path(@other_codeplug, @other_zone), params: {
      positions: [
        { id: cz.id, position: 2 }
      ]
    }, as: :json

    assert_redirected_to codeplugs_path
  end

  test "should require login for update_positions" do
    patch update_positions_codeplug_zone_path(@codeplug, @zone), params: {
      positions: []
    }, as: :json

    assert_redirected_to login_path
  end
end
