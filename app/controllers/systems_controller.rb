class SystemsController < ApplicationController
  before_action :set_system, only: [ :show, :edit, :update, :destroy ]

  def index
    @systems = System.includes(:mode_detail).order(:name)
  end

  def show
    @available_talk_groups = available_talk_groups_for_system(@system)
  end

  def new
    @system = System.new
    @networks = Network.order(:name)
  end

  def edit
    @networks = Network.order(:name)
  end

  def create
    @system = System.new(system_params)

    if @system.save
      redirect_to system_path(@system), notice: "System was successfully created."
    else
      @networks = Network.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @system.update(system_params)
      redirect_to system_path(@system), notice: "System was successfully updated."
    else
      @networks = Network.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @system.destroy!
    redirect_to systems_path, notice: "System was successfully deleted."
  end

  private

  def set_system
    @system = System.includes(:mode_detail, :networks, system_talk_groups: :talk_group).find(params[:id])
  end

  def system_params
    params.require(:system).permit(
      :name, :mode, :tx_frequency, :rx_frequency, :bandwidth,
      :supports_tx_tone, :supports_rx_tone, :tx_tone_value, :rx_tone_value,
      :city, :state, :county, :latitude, :longitude,
      :color_code, :nac,
      network_ids: []
    )
  end

  def available_talk_groups_for_system(system)
    case system.mode
    when "analog"
      # Analog systems cannot have talkgroups
      TalkGroup.none
    when "p25"
      # P25 systems can only use talkgroups from P25 networks
      TalkGroup.joins(:network).where(networks: { network_type: "Digital-P25" }).order(:name)
    when "dmr"
      # DMR systems can only use talkgroups from their associated networks
      if system.networks.any?
        TalkGroup.where(network_id: system.network_ids).order(:name)
      else
        TalkGroup.none
      end
    else
      # NXDN and other modes - show all talkgroups for now
      TalkGroup.includes(:network).order(:name)
    end
  end
end
