class ChannelsController < ApplicationController
  before_action :set_codeplug
  before_action :set_channel, only: [ :show, :edit, :update, :destroy ]

  def index
    @channels = @codeplug.channels.includes(:system, :system_talk_group).order(:name)
  end

  def show
    # Display channel details
  end

  def new
    @channel = @codeplug.channels.build
    load_form_data
  end

  def edit
    load_form_data
  end

  def create
    @channel = @codeplug.channels.build(channel_params)

    if @channel.save
      redirect_to codeplug_channel_path(@codeplug, @channel), notice: "Channel was successfully created."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @channel.update(channel_params)
      redirect_to codeplug_channel_path(@codeplug, @channel), notice: "Channel was successfully updated."
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @channel.destroy!
    redirect_to codeplug_channels_path(@codeplug), notice: "Channel was successfully deleted."
  end

  private

  def set_codeplug
    @codeplug = Codeplug.find(params[:codeplug_id])
  end

  def set_channel
    @channel = @codeplug.channels.find(params[:id])
  end

  def load_form_data
    @systems = System.order(:name)
    @system_talk_groups = SystemTalkGroup.includes(:talk_group, :system).order("talk_groups.name")
    # Group system talk groups by system_id for JavaScript filtering
    @system_talk_groups_by_system = @system_talk_groups.group_by(&:system_id)
  end

  def channel_params
    params.require(:channel).permit(
      :name, :long_name, :short_name, :system_id, :system_talk_group_id,
      :power_level, :bandwidth, :tone_mode, :transmit_permission
    )
  end
end
