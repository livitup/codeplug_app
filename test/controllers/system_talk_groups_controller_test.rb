require "test_helper"

class SystemTalkGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @system = create(:system, mode: "dmr")
    @talk_group = create(:talk_group)
  end

  # Create Action Tests
  test "should create system_talk_group association" do
    log_in_as(@user)

    assert_difference("SystemTalkGroup.count", 1) do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          talk_group_id: @talk_group.id,
          timeslot: 1
        }
      }
    end

    assert_redirected_to system_path(@system)
    assert_equal "TalkGroup was successfully added.", flash[:notice]
  end

  test "should create system_talk_group with turbo_stream format" do
    log_in_as(@user)

    assert_difference("SystemTalkGroup.count", 1) do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          talk_group_id: @talk_group.id,
          timeslot: 1
        }
      }, as: :turbo_stream
    end

    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  test "should create system_talk_group without timeslot for non-DMR" do
    log_in_as(@user)
    analog_system = create(:system, :analog)

    assert_difference("SystemTalkGroup.count", 1) do
      post system_system_talk_groups_path(analog_system), params: {
        system_talk_group: {
          talk_group_id: @talk_group.id,
          timeslot: nil
        }
      }
    end

    assert_redirected_to system_path(analog_system)
  end

  test "should not create system_talk_group without timeslot for DMR" do
    log_in_as(@user)

    assert_no_difference("SystemTalkGroup.count") do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          talk_group_id: @talk_group.id,
          timeslot: nil
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create duplicate system_talk_group with same timeslot" do
    log_in_as(@user)
    # Create first association
    create(:system_talk_group, system: @system, talk_group: @talk_group, timeslot: 1)

    # Try to create duplicate
    assert_no_difference("SystemTalkGroup.count") do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          talk_group_id: @talk_group.id,
          timeslot: 1
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should handle duplicate error with turbo_stream format" do
    log_in_as(@user)
    # Create first association
    create(:system_talk_group, system: @system, talk_group: @talk_group, timeslot: 1)

    # Try to create duplicate with turbo_stream
    assert_no_difference("SystemTalkGroup.count") do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          talk_group_id: @talk_group.id,
          timeslot: 1
        }
      }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  test "should handle missing talk_group_id with turbo_stream format" do
    log_in_as(@user)

    assert_no_difference("SystemTalkGroup.count") do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          timeslot: 1
        }
      }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  test "should allow same talkgroup on different timeslots" do
    log_in_as(@user)
    # Create association on timeslot 1
    create(:system_talk_group, system: @system, talk_group: @talk_group, timeslot: 1)

    # Create association on timeslot 2 (should succeed)
    assert_difference("SystemTalkGroup.count", 1) do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          talk_group_id: @talk_group.id,
          timeslot: 2
        }
      }
    end

    assert_redirected_to system_path(@system)
  end

  test "should not create system_talk_group with invalid timeslot" do
    log_in_as(@user)

    assert_no_difference("SystemTalkGroup.count") do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          talk_group_id: @talk_group.id,
          timeslot: 3
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create system_talk_group without talk_group_id" do
    log_in_as(@user)

    assert_no_difference("SystemTalkGroup.count") do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          timeslot: 1
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should require login to create system_talk_group" do
    assert_no_difference("SystemTalkGroup.count") do
      post system_system_talk_groups_path(@system), params: {
        system_talk_group: {
          talk_group_id: @talk_group.id,
          timeslot: 1
        }
      }
    end

    assert_redirected_to login_path
  end

  # Destroy Action Tests
  test "should destroy system_talk_group" do
    log_in_as(@user)
    system_talk_group = create(:system_talk_group, system: @system, talk_group: @talk_group)

    assert_difference("SystemTalkGroup.count", -1) do
      delete system_system_talk_group_path(@system, system_talk_group)
    end

    assert_redirected_to system_path(@system)
    assert_equal "TalkGroup was successfully removed.", flash[:notice]
  end

  test "should destroy system_talk_group with turbo_stream format" do
    log_in_as(@user)
    system_talk_group = create(:system_talk_group, system: @system, talk_group: @talk_group)

    assert_difference("SystemTalkGroup.count", -1) do
      delete system_system_talk_group_path(@system, system_talk_group), as: :turbo_stream
    end

    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  test "should require login to destroy system_talk_group" do
    system_talk_group = create(:system_talk_group, system: @system, talk_group: @talk_group)

    assert_no_difference("SystemTalkGroup.count") do
      delete system_system_talk_group_path(@system, system_talk_group)
    end

    assert_redirected_to login_path
  end
end
