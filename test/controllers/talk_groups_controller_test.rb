require "test_helper"

class TalkGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    log_in_as(@user)
    @network = create(:network)
    @talk_group = create(:talk_group, network: @network)
  end

  # Index Tests
  test "should get index" do
    get talk_groups_path
    assert_response :success
  end

  test "index should display talk groups" do
    get talk_groups_path
    assert_select "h1", "TalkGroups"
  end

  test "index should display talk group names and numbers" do
    tg1 = create(:talk_group, network: @network, name: "Virginia", talkgroup_number: "3151")
    tg2 = create(:talk_group, network: @network, name: "Worldwide", talkgroup_number: "91")
    get talk_groups_path
    assert_select "td", tg1.name
    assert_select "td", tg1.talkgroup_number
    assert_select "td", tg2.name
    assert_select "td", tg2.talkgroup_number
  end

  test "index should filter by network" do
    network2 = create(:network, name: "DMRVA")
    tg1 = create(:talk_group, network: @network, name: "Network 1 TG")
    tg2 = create(:talk_group, network: network2, name: "Network 2 TG")

    get talk_groups_path, params: { network_id: @network.id }
    assert_response :success
    assert_select "td", tg1.name
    assert_select "td", { text: tg2.name, count: 0 }
  end

  # Show Tests
  test "should get show" do
    get talk_group_path(@talk_group)
    assert_response :success
  end

  test "show should display talk group name" do
    get talk_group_path(@talk_group)
    assert_select "h1", @talk_group.name
  end

  test "show should display talk group details" do
    tg = create(:talk_group,
      network: @network,
      name: "Virginia",
      talkgroup_number: "3151",
      description: "Virginia statewide talkgroup")
    get talk_group_path(tg)
    assert_select "dd", "Virginia"
    assert_select "dd", "3151"
    assert_select "dd", "Virginia statewide talkgroup"
  end

  # New Tests
  test "should get new" do
    get new_talk_group_path
    assert_response :success
  end

  test "new should display form" do
    get new_talk_group_path
    assert_select "form"
  end

  # Create Tests
  test "should create talk_group with valid attributes" do
    assert_difference("TalkGroup.count", 1) do
      post talk_groups_path, params: {
        talk_group: {
          network_id: @network.id,
          name: "Test TalkGroup",
          talkgroup_number: "9999"
        }
      }
    end
    assert_redirected_to talk_group_path(TalkGroup.last)
  end

  test "should create talk_group with all attributes" do
    assert_difference("TalkGroup.count", 1) do
      post talk_groups_path, params: {
        talk_group: {
          network_id: @network.id,
          name: "Full TalkGroup",
          talkgroup_number: "8888",
          description: "A complete talkgroup"
        }
      }
    end
    tg = TalkGroup.last
    assert_equal "Full TalkGroup", tg.name
    assert_equal "8888", tg.talkgroup_number
    assert_equal "A complete talkgroup", tg.description
    assert_equal @network, tg.network
  end

  test "should not create talk_group with invalid attributes" do
    assert_no_difference("TalkGroup.count") do
      post talk_groups_path, params: {
        talk_group: {
          network_id: @network.id,
          name: ""
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create talk_group with duplicate talkgroup_number in same network" do
    create(:talk_group, network: @network, talkgroup_number: "3151")
    assert_no_difference("TalkGroup.count") do
      post talk_groups_path, params: {
        talk_group: {
          network_id: @network.id,
          name: "Duplicate",
          talkgroup_number: "3151"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit Tests
  test "should get edit" do
    get edit_talk_group_path(@talk_group)
    assert_response :success
  end

  test "edit should display form with existing values" do
    get edit_talk_group_path(@talk_group)
    assert_select "form"
    assert_select "input[value=?]", @talk_group.name
  end

  # Update Tests
  test "should update talk_group with valid attributes" do
    patch talk_group_path(@talk_group), params: {
      talk_group: {
        name: "Updated Name"
      }
    }
    assert_redirected_to talk_group_path(@talk_group)
    @talk_group.reload
    assert_equal "Updated Name", @talk_group.name
  end

  test "should update talk_group with all attributes" do
    patch talk_group_path(@talk_group), params: {
      talk_group: {
        name: "Updated TalkGroup",
        talkgroup_number: "7777",
        description: "Updated description"
      }
    }
    assert_redirected_to talk_group_path(@talk_group)
    @talk_group.reload
    assert_equal "Updated TalkGroup", @talk_group.name
    assert_equal "7777", @talk_group.talkgroup_number
    assert_equal "Updated description", @talk_group.description
  end

  test "should not update talk_group with invalid attributes" do
    original_name = @talk_group.name
    patch talk_group_path(@talk_group), params: {
      talk_group: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
    @talk_group.reload
    assert_equal original_name, @talk_group.name
  end

  # Destroy Tests
  test "should destroy talk_group" do
    assert_difference("TalkGroup.count", -1) do
      delete talk_group_path(@talk_group)
    end
    assert_redirected_to talk_groups_path
    assert_equal "TalkGroup was successfully deleted.", flash[:notice]
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
