require "test_helper"

class ZoneSystemTalkgroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    @zone = create(:zone, user: @user, name: "Test Zone")
    @other_zone = create(:zone, user: @other_user, name: "Other Zone")

    # Create DMR system with network for talkgroups
    @dmr_network = create(:network, network_type: "Digital-DMR")
    @dmr_system = create(:system, mode: "dmr", color_code: 1, name: "DMR System")
    @dmr_system.networks << @dmr_network

    # Create another DMR system for cross-system validation tests
    @other_dmr_system = create(:system, mode: "dmr", color_code: 2, name: "Other DMR System")
    @other_dmr_system.networks << @dmr_network

    # Create talkgroups on the DMR network
    @talkgroup1 = create(:talk_group, name: "TG 1", talkgroup_number: "1001", network: @dmr_network)
    @talkgroup2 = create(:talk_group, name: "TG 2", talkgroup_number: "1002", network: @dmr_network)
    @talkgroup3 = create(:talk_group, name: "TG 3", talkgroup_number: "1003", network: @dmr_network)

    # Create SystemTalkGroups (talkgroups on the system)
    @system_talkgroup1 = create(:system_talk_group, system: @dmr_system, talk_group: @talkgroup1, timeslot: 1)
    @system_talkgroup2 = create(:system_talk_group, system: @dmr_system, talk_group: @talkgroup2, timeslot: 2)
    @system_talkgroup3 = create(:system_talk_group, system: @dmr_system, talk_group: @talkgroup3, timeslot: 1)

    # Create SystemTalkGroup on other system (for cross-system validation tests)
    @other_system_talkgroup = create(:system_talk_group, system: @other_dmr_system, talk_group: @talkgroup1, timeslot: 1)

    # Create ZoneSystem (system added to zone)
    @zone_system = create(:zone_system, zone: @zone, system: @dmr_system, position: 1)
    @other_zone_system = create(:zone_system, zone: @other_zone, system: @dmr_system, position: 1)
  end

  # Create Action Tests
  test "should add talkgroup to zone system" do
    log_in_as(@user)

    assert_difference("ZoneSystemTalkGroup.count", 1) do
      post zone_zone_system_zone_system_talkgroups_path(@zone, @zone_system), params: {
        zone_system_talk_group: {
          system_talk_group_id: @system_talkgroup1.id
        }
      }
    end

    assert_redirected_to zone_path(@zone)
    assert_equal "Talkgroup was successfully added.", flash[:notice]

    zone_system_talkgroup = ZoneSystemTalkGroup.last
    assert_equal @zone_system, zone_system_talkgroup.zone_system
    assert_equal @system_talkgroup1, zone_system_talkgroup.system_talk_group
  end

  test "should not add duplicate talkgroup to zone system" do
    log_in_as(@user)
    create(:zone_system_talk_group, zone_system: @zone_system, system_talk_group: @system_talkgroup1)

    assert_no_difference("ZoneSystemTalkGroup.count") do
      post zone_zone_system_zone_system_talkgroups_path(@zone, @zone_system), params: {
        zone_system_talk_group: {
          system_talk_group_id: @system_talkgroup1.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not add talkgroup from different system" do
    log_in_as(@user)

    assert_no_difference("ZoneSystemTalkGroup.count") do
      post zone_zone_system_zone_system_talkgroups_path(@zone, @zone_system), params: {
        zone_system_talk_group: {
          system_talk_group_id: @other_system_talkgroup.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not add talkgroup to other user's zone" do
    log_in_as(@user)

    assert_no_difference("ZoneSystemTalkGroup.count") do
      post zone_zone_system_zone_system_talkgroups_path(@other_zone, @other_zone_system), params: {
        zone_system_talk_group: {
          system_talk_group_id: @system_talkgroup1.id
        }
      }
    end

    assert_response :forbidden
  end

  test "should require login for create" do
    assert_no_difference("ZoneSystemTalkGroup.count") do
      post zone_zone_system_zone_system_talkgroups_path(@zone, @zone_system), params: {
        zone_system_talk_group: {
          system_talk_group_id: @system_talkgroup1.id
        }
      }
    end

    assert_redirected_to login_path
  end

  # Destroy Action Tests
  test "should remove talkgroup from zone system" do
    log_in_as(@user)
    zone_system_talkgroup = create(:zone_system_talk_group, zone_system: @zone_system, system_talk_group: @system_talkgroup1)

    assert_difference("ZoneSystemTalkGroup.count", -1) do
      delete zone_zone_system_zone_system_talkgroup_path(@zone, @zone_system, zone_system_talkgroup)
    end

    assert_redirected_to zone_path(@zone)
    assert_equal "Talkgroup was successfully removed.", flash[:notice]
  end

  test "should not remove talkgroup from other user's zone" do
    log_in_as(@user)
    zone_system_talkgroup = create(:zone_system_talk_group, zone_system: @other_zone_system, system_talk_group: @system_talkgroup1)

    assert_no_difference("ZoneSystemTalkGroup.count") do
      delete zone_zone_system_zone_system_talkgroup_path(@other_zone, @other_zone_system, zone_system_talkgroup)
    end

    assert_response :forbidden
  end

  test "should require login for destroy" do
    zone_system_talkgroup = create(:zone_system_talk_group, zone_system: @zone_system, system_talk_group: @system_talkgroup1)

    assert_no_difference("ZoneSystemTalkGroup.count") do
      delete zone_zone_system_zone_system_talkgroup_path(@zone, @zone_system, zone_system_talkgroup)
    end

    assert_redirected_to login_path
  end

  # Multiple talkgroups per zone system
  test "should allow multiple talkgroups per zone system" do
    log_in_as(@user)

    # Add first talkgroup
    post zone_zone_system_zone_system_talkgroups_path(@zone, @zone_system), params: {
      zone_system_talk_group: { system_talk_group_id: @system_talkgroup1.id }
    }
    assert_redirected_to zone_path(@zone)

    # Add second talkgroup
    post zone_zone_system_zone_system_talkgroups_path(@zone, @zone_system), params: {
      zone_system_talk_group: { system_talk_group_id: @system_talkgroup2.id }
    }
    assert_redirected_to zone_path(@zone)

    # Add third talkgroup
    post zone_zone_system_zone_system_talkgroups_path(@zone, @zone_system), params: {
      zone_system_talk_group: { system_talk_group_id: @system_talkgroup3.id }
    }
    assert_redirected_to zone_path(@zone)

    assert_equal 3, @zone_system.zone_system_talkgroups.count
  end
end
