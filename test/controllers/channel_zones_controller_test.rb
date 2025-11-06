require "test_helper"

class ChannelZonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    @codeplug = create(:codeplug, user: @user)
    @other_codeplug = create(:codeplug, user: @other_user)
    @zone = create(:zone, codeplug: @codeplug, name: "Zone 1")
    @other_zone = create(:zone, codeplug: @other_codeplug, name: "Other Zone")
    @system = create(:system)
    @channel = create(:channel, codeplug: @codeplug, system: @system, long_name: "Channel 1")
    @other_channel = create(:channel, codeplug: @other_codeplug, system: @system, long_name: "Other Channel")
  end

  # Create Action Tests
  test "should add channel to own zone" do
    log_in_as(@user)

    assert_difference("ChannelZone.count", 1) do
      post codeplug_zone_channel_zones_path(@codeplug, @zone), params: {
        channel_zone: {
          channel_id: @channel.id
        }
      }
    end

    channel_zone = ChannelZone.last
    assert_equal @zone, channel_zone.zone
    assert_equal @channel, channel_zone.channel
    assert_equal 1, channel_zone.position
    assert_redirected_to codeplug_zone_path(@codeplug, @zone)
    assert_equal "Channel was successfully added to zone.", flash[:notice]
  end

  test "should set correct position when adding channel to zone with existing channels" do
    log_in_as(@user)
    channel2 = create(:channel, codeplug: @codeplug, system: @system, long_name: "Channel 2")
    channel3 = create(:channel, codeplug: @codeplug, system: @system, long_name: "Channel 3")
    create(:channel_zone, zone: @zone, channel: @channel, position: 1)
    create(:channel_zone, zone: @zone, channel: channel2, position: 2)

    assert_difference("ChannelZone.count", 1) do
      post codeplug_zone_channel_zones_path(@codeplug, @zone), params: {
        channel_zone: {
          channel_id: channel3.id
        }
      }
    end

    channel_zone = ChannelZone.last
    assert_equal 3, channel_zone.position
  end

  test "should not add channel from other user's codeplug to zone" do
    log_in_as(@user)

    assert_no_difference("ChannelZone.count") do
      post codeplug_zone_channel_zones_path(@codeplug, @zone), params: {
        channel_zone: {
          channel_id: @other_channel.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not add duplicate channel to zone" do
    log_in_as(@user)
    create(:channel_zone, zone: @zone, channel: @channel, position: 1)

    assert_no_difference("ChannelZone.count") do
      post codeplug_zone_channel_zones_path(@codeplug, @zone), params: {
        channel_zone: {
          channel_id: @channel.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not add channel to other user's zone" do
    log_in_as(@user)

    assert_no_difference("ChannelZone.count") do
      post codeplug_zone_channel_zones_path(@other_codeplug, @other_zone), params: {
        channel_zone: {
          channel_id: @channel.id
        }
      }
    end

    assert_redirected_to codeplugs_path
  end

  test "should require login for create" do
    assert_no_difference("ChannelZone.count") do
      post codeplug_zone_channel_zones_path(@codeplug, @zone), params: {
        channel_zone: {
          channel_id: @channel.id
        }
      }
    end

    assert_redirected_to login_path
  end

  # Destroy Action Tests
  test "should remove channel from own zone" do
    log_in_as(@user)
    channel_zone = create(:channel_zone, zone: @zone, channel: @channel, position: 1)

    assert_difference("ChannelZone.count", -1) do
      delete codeplug_zone_channel_zone_path(@codeplug, @zone, channel_zone)
    end

    assert_redirected_to codeplug_zone_path(@codeplug, @zone)
    assert_equal "Channel was successfully removed from zone.", flash[:notice]
  end

  test "should not remove channel from other user's zone" do
    log_in_as(@user)
    other_channel_zone = create(:channel_zone, zone: @other_zone, channel: @other_channel, position: 1)

    assert_no_difference("ChannelZone.count") do
      delete codeplug_zone_channel_zone_path(@other_codeplug, @other_zone, other_channel_zone)
    end

    assert_redirected_to codeplugs_path
  end

  test "should require login for destroy" do
    channel_zone = create(:channel_zone, zone: @zone, channel: @channel, position: 1)

    assert_no_difference("ChannelZone.count") do
      delete codeplug_zone_channel_zone_path(@codeplug, @zone, channel_zone)
    end

    assert_redirected_to login_path
  end
end
