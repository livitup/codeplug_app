require "test_helper"

class CodeplugsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    @codeplug = create(:codeplug, user: @user, name: "My Codeplug")
    @other_codeplug = create(:codeplug, user: @other_user, name: "Other User's Codeplug")
  end

  # Index Action Tests
  test "should get index when logged in" do
    log_in_as(@user)
    get codeplugs_path

    assert_response :success
    assert_select "h1", "Codeplugs"
  end

  test "should show only current user's codeplugs in index" do
    log_in_as(@user)
    get codeplugs_path

    assert_response :success
    assert_select "td", text: @codeplug.name
    assert_select "td", text: @other_codeplug.name, count: 0
  end

  test "should redirect to login when not logged in" do
    get codeplugs_path
    assert_redirected_to login_path
  end

  # Show Action Tests
  test "should show codeplug for owner" do
    log_in_as(@user)
    get codeplug_path(@codeplug)

    assert_response :success
    assert_select "h1", @codeplug.name
  end

  test "should not show other user's private codeplug" do
    log_in_as(@user)
    get codeplug_path(@other_codeplug)

    assert_redirected_to codeplugs_path
    assert_equal "You don't have permission to access this codeplug.", flash[:alert]
  end

  test "should show public codeplug to any user" do
    public_codeplug = create(:codeplug, :public, user: @other_user, name: "Public Codeplug")
    log_in_as(@user)
    get codeplug_path(public_codeplug)

    assert_response :success
    assert_select "h1", public_codeplug.name
  end

  # New Action Tests
  test "should get new when logged in" do
    log_in_as(@user)
    get new_codeplug_path

    assert_response :success
    assert_select "h1", "New Codeplug"
  end

  test "should not get new when not logged in" do
    get new_codeplug_path
    assert_redirected_to login_path
  end

  # Create Action Tests
  test "should create codeplug for current user" do
    log_in_as(@user)

    assert_difference("Codeplug.count", 1) do
      post codeplugs_path, params: {
        codeplug: {
          name: "Test Codeplug",
          description: "Test description",
          public: false
        }
      }
    end

    codeplug = Codeplug.last
    assert_equal @user, codeplug.user
    assert_redirected_to codeplug_path(codeplug)
    assert_equal "Codeplug was successfully created.", flash[:notice]
  end

  test "should not create codeplug without name" do
    log_in_as(@user)

    assert_no_difference("Codeplug.count") do
      post codeplugs_path, params: {
        codeplug: {
          name: "",
          description: "Test"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create codeplug when not logged in" do
    assert_no_difference("Codeplug.count") do
      post codeplugs_path, params: {
        codeplug: {
          name: "Test",
          description: "Test"
        }
      }
    end

    assert_redirected_to login_path
  end

  # Edit Action Tests
  test "should get edit for own codeplug" do
    log_in_as(@user)
    get edit_codeplug_path(@codeplug)

    assert_response :success
    assert_select "h1", text: /Edit Codeplug/
  end

  test "should not get edit for other user's codeplug" do
    log_in_as(@user)
    get edit_codeplug_path(@other_codeplug)

    assert_redirected_to codeplugs_path
    assert_equal "You don't have permission to access this codeplug.", flash[:alert]
  end

  test "should not get edit when not logged in" do
    get edit_codeplug_path(@codeplug)
    assert_redirected_to login_path
  end

  # Update Action Tests
  test "should update own codeplug" do
    log_in_as(@user)

    patch codeplug_path(@codeplug), params: {
      codeplug: {
        name: "Updated Name",
        description: "Updated description"
      }
    }

    @codeplug.reload
    assert_equal "Updated Name", @codeplug.name
    assert_equal "Updated description", @codeplug.description
    assert_redirected_to codeplug_path(@codeplug)
    assert_equal "Codeplug was successfully updated.", flash[:notice]
  end

  test "should not update other user's codeplug" do
    log_in_as(@user)
    original_name = @other_codeplug.name

    patch codeplug_path(@other_codeplug), params: {
      codeplug: {
        name: "Hacked Name"
      }
    }

    @other_codeplug.reload
    assert_equal original_name, @other_codeplug.name
    assert_redirected_to codeplugs_path
  end

  test "should not update without name" do
    log_in_as(@user)

    patch codeplug_path(@codeplug), params: {
      codeplug: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
  end

  test "should not update when not logged in" do
    patch codeplug_path(@codeplug), params: {
      codeplug: {
        name: "New Name"
      }
    }

    assert_redirected_to login_path
  end

  # Destroy Action Tests
  test "should destroy own codeplug" do
    log_in_as(@user)

    assert_difference("Codeplug.count", -1) do
      delete codeplug_path(@codeplug)
    end

    assert_redirected_to codeplugs_path
    assert_equal "Codeplug was successfully deleted.", flash[:notice]
  end

  test "should not destroy other user's codeplug" do
    log_in_as(@user)

    assert_no_difference("Codeplug.count") do
      delete codeplug_path(@other_codeplug)
    end

    assert_redirected_to codeplugs_path
  end

  test "should not destroy when not logged in" do
    assert_no_difference("Codeplug.count") do
      delete codeplug_path(@codeplug)
    end

    assert_redirected_to login_path
  end

  # Public/Private Visibility Tests
  test "should toggle public flag" do
    log_in_as(@user)
    assert_not @codeplug.public

    patch codeplug_path(@codeplug), params: {
      codeplug: {
        public: true
      }
    }

    @codeplug.reload
    assert @codeplug.public
  end

  # Generate Channels Action Tests
  test "should generate channels for own codeplug" do
    log_in_as(@user)

    # Set up a zone with an analog system
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)
    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    assert_difference "Channel.count", 1 do
      post generate_channels_codeplug_path(@codeplug)
    end

    assert_redirected_to codeplug_path(@codeplug)
    assert_match /generated 1 channel/, flash[:notice]
  end

  test "should not generate channels for other user's codeplug" do
    log_in_as(@user)

    assert_no_difference "Channel.count" do
      post generate_channels_codeplug_path(@other_codeplug)
    end

    assert_redirected_to codeplugs_path
  end

  test "should require login for generate_channels" do
    post generate_channels_codeplug_path(@codeplug)
    assert_redirected_to login_path
  end

  test "should skip generation if channels exist and no confirmation" do
    log_in_as(@user)

    # Create an existing channel
    system = create(:system, :analog)
    create(:channel, codeplug: @codeplug, system: system, name: "Existing Channel")

    # Set up a zone
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)
    analog_system = create(:system, :analog, name: "W4BK Repeater")
    create(:zone_system, zone: zone, system: analog_system, position: 1)

    assert_no_difference "Channel.count" do
      post generate_channels_codeplug_path(@codeplug)
    end

    assert_redirected_to codeplug_path(@codeplug)
    assert_match /already has.*channel/, flash[:alert]
  end

  test "should regenerate channels with confirmation" do
    log_in_as(@user)

    # Create an existing channel
    system = create(:system, :analog)
    existing_channel = create(:channel, codeplug: @codeplug, system: system, name: "Existing Channel")

    # Set up a zone with 2 systems
    zone = create(:zone, user: @user, name: "Test Zone")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone, position: 1)
    analog_system1 = create(:system, :analog, name: "System 1")
    analog_system2 = create(:system, :analog, name: "System 2")
    create(:zone_system, zone: zone, system: analog_system1, position: 1)
    create(:zone_system, zone: zone, system: analog_system2, position: 2)

    # Should regenerate (delete 1 old, create 2 new = net +1)
    assert_difference "Channel.count", 1 do
      post generate_channels_codeplug_path(@codeplug), params: { confirm_regenerate: "true" }
    end

    assert_redirected_to codeplug_path(@codeplug)
    assert_match /generated 2 channel/, flash[:notice]
    assert_not Channel.exists?(existing_channel.id)
  end

  test "should show message when no zones to generate from" do
    log_in_as(@user)

    post generate_channels_codeplug_path(@codeplug)

    assert_redirected_to codeplug_path(@codeplug)
    assert_match /0 channel|0 zone/, flash[:notice]
  end

  test "should generate channels from multiple zones" do
    log_in_as(@user)

    # Set up 2 zones with systems
    zone1 = create(:zone, user: @user, name: "Zone 1")
    zone2 = create(:zone, user: @user, name: "Zone 2")
    create(:codeplug_zone, codeplug: @codeplug, zone: zone1, position: 1)
    create(:codeplug_zone, codeplug: @codeplug, zone: zone2, position: 2)

    analog_system1 = create(:system, :analog, name: "System 1")
    analog_system2 = create(:system, :analog, name: "System 2")
    create(:zone_system, zone: zone1, system: analog_system1, position: 1)
    create(:zone_system, zone: zone2, system: analog_system2, position: 1)

    assert_difference "Channel.count", 2 do
      post generate_channels_codeplug_path(@codeplug)
    end

    assert_match /generated 2 channel.*2 zone/, flash[:notice]
  end
end
