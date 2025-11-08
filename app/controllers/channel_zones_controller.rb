class ChannelZonesController < ApplicationController
  before_action :set_codeplug
  before_action :set_zone
  before_action :authorize_codeplug
  before_action :set_channel_zone, only: [ :destroy ]

  def create
    @channel = @codeplug.channels.find_by(id: channel_zone_params[:channel_id])

    unless @channel
      flash[:alert] = "Channel not found in this codeplug."
      redirect_to codeplug_zone_path(@codeplug, @zone), status: :unprocessable_entity
      return
    end

    # Get the next available position
    max_position = @zone.channel_zones.maximum(:position) || 0
    @channel_zone = @zone.channel_zones.new(
      channel: @channel,
      position: max_position + 1
    )

    if @channel_zone.save
      redirect_to codeplug_zone_path(@codeplug, @zone), notice: "Channel was successfully added to zone."
    else
      flash[:alert] = @channel_zone.errors.full_messages.join(", ")
      redirect_to codeplug_zone_path(@codeplug, @zone), status: :unprocessable_entity
    end
  end

  def destroy
    @channel_zone.destroy!
    redirect_to codeplug_zone_path(@codeplug, @zone), notice: "Channel was successfully removed from zone."
  end

  private

  def set_codeplug
    @codeplug = Codeplug.find(params[:codeplug_id])
  end

  def set_zone
    @zone = @codeplug.zones.find(params[:zone_id])
  end

  def set_channel_zone
    @channel_zone = @zone.channel_zones.find(params[:id])
  end

  def authorize_codeplug
    unless @codeplug.user == current_user
      redirect_to codeplugs_path, alert: "You don't have permission to access this codeplug."
    end
  end

  def channel_zone_params
    params.require(:channel_zone).permit(:channel_id)
  end
end
