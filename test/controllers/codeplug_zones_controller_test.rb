require "test_helper"

class CodeplugZonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    @codeplug = create(:codeplug, user: @user, name: "My Codeplug")
    @other_codeplug = create(:codeplug, user: @other_user, name: "Other Codeplug")

    # Create zones
    @my_zone = create(:zone, user: @user, name: "My Zone", public: false)
    @my_zone2 = create(:zone, user: @user, name: "My Zone 2", public: false)
    @public_zone = create(:zone, user: @other_user, name: "Public Zone", public: true)
    @private_zone = create(:zone, user: @other_user, name: "Private Zone", public: false)
  end

  # Create Action Tests
  test "should add own zone to codeplug" do
    log_in_as(@user)

    assert_difference("CodeplugZone.count", 1) do
      post codeplug_codeplug_zones_path(@codeplug), params: {
        codeplug_zone: { zone_id: @my_zone.id }
      }
    end

    assert_redirected_to codeplug_path(@codeplug)
    assert_equal "Zone was successfully added to codeplug.", flash[:notice]

    codeplug_zone = CodeplugZone.last
    assert_equal @codeplug, codeplug_zone.codeplug
    assert_equal @my_zone, codeplug_zone.zone
    assert_equal 1, codeplug_zone.position
  end

  test "should add public zone to codeplug" do
    log_in_as(@user)

    assert_difference("CodeplugZone.count", 1) do
      post codeplug_codeplug_zones_path(@codeplug), params: {
        codeplug_zone: { zone_id: @public_zone.id }
      }
    end

    assert_redirected_to codeplug_path(@codeplug)
    assert_equal "Zone was successfully added to codeplug.", flash[:notice]
  end

  test "should auto-assign next position when adding zone" do
    log_in_as(@user)

    # Add first zone
    create(:codeplug_zone, codeplug: @codeplug, zone: @my_zone, position: 1)

    # Add second zone
    post codeplug_codeplug_zones_path(@codeplug), params: {
      codeplug_zone: { zone_id: @my_zone2.id }
    }

    codeplug_zone = CodeplugZone.last
    assert_equal 2, codeplug_zone.position
  end

  test "should not add duplicate zone to codeplug" do
    log_in_as(@user)
    create(:codeplug_zone, codeplug: @codeplug, zone: @my_zone, position: 1)

    assert_no_difference("CodeplugZone.count") do
      post codeplug_codeplug_zones_path(@codeplug), params: {
        codeplug_zone: { zone_id: @my_zone.id }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not add other user's private zone to codeplug" do
    log_in_as(@user)

    assert_no_difference("CodeplugZone.count") do
      post codeplug_codeplug_zones_path(@codeplug), params: {
        codeplug_zone: { zone_id: @private_zone.id }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not add zone to other user's codeplug" do
    log_in_as(@user)

    assert_no_difference("CodeplugZone.count") do
      post codeplug_codeplug_zones_path(@other_codeplug), params: {
        codeplug_zone: { zone_id: @my_zone.id }
      }
    end

    assert_response :forbidden
  end

  test "should require login for create" do
    assert_no_difference("CodeplugZone.count") do
      post codeplug_codeplug_zones_path(@codeplug), params: {
        codeplug_zone: { zone_id: @my_zone.id }
      }
    end

    assert_redirected_to login_path
  end

  # Destroy Action Tests
  test "should remove zone from codeplug" do
    log_in_as(@user)
    codeplug_zone = create(:codeplug_zone, codeplug: @codeplug, zone: @my_zone, position: 1)

    assert_difference("CodeplugZone.count", -1) do
      delete codeplug_codeplug_zone_path(@codeplug, codeplug_zone)
    end

    assert_redirected_to codeplug_path(@codeplug)
    assert_equal "Zone was successfully removed from codeplug.", flash[:notice]
  end

  test "should reorder positions after removing zone" do
    log_in_as(@user)
    cz1 = create(:codeplug_zone, codeplug: @codeplug, zone: @my_zone, position: 1)
    cz2 = create(:codeplug_zone, codeplug: @codeplug, zone: @my_zone2, position: 2)
    cz3 = create(:codeplug_zone, codeplug: @codeplug, zone: @public_zone, position: 3)

    # Remove middle zone
    delete codeplug_codeplug_zone_path(@codeplug, cz2)

    # Verify positions are reordered
    assert_equal 1, cz1.reload.position
    assert_equal 2, cz3.reload.position
  end

  test "should not remove zone from other user's codeplug" do
    log_in_as(@user)
    codeplug_zone = create(:codeplug_zone, codeplug: @other_codeplug, zone: @public_zone, position: 1)

    assert_no_difference("CodeplugZone.count") do
      delete codeplug_codeplug_zone_path(@other_codeplug, codeplug_zone)
    end

    assert_response :forbidden
  end

  test "should require login for destroy" do
    codeplug_zone = create(:codeplug_zone, codeplug: @codeplug, zone: @my_zone, position: 1)

    assert_no_difference("CodeplugZone.count") do
      delete codeplug_codeplug_zone_path(@codeplug, codeplug_zone)
    end

    assert_redirected_to login_path
  end
end
