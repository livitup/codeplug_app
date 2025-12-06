class SystemTalkGroupsController < ApplicationController
  before_action :set_system
  before_action :set_available_talk_groups, only: [ :create ]

  def create
    @system_talk_group = @system.system_talk_groups.build(system_talk_group_params)

    if @system_talk_group.save
      respond_to do |format|
        format.html { redirect_to system_path(@system), notice: "TalkGroup was successfully added." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to system_path(@system), alert: "Failed to add TalkGroup.", status: :unprocessable_entity }
        format.turbo_stream { render :error, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @system_talk_group = @system.system_talk_groups.find(params[:id])
    @system_talk_group.destroy!
    @system.reload

    respond_to do |format|
      format.html { redirect_to system_path(@system), notice: "TalkGroup was successfully removed." }
      format.turbo_stream
    end
  end

  private

  def set_system
    @system = System.find(params[:system_id])
  end

  def set_available_talk_groups
    @available_talk_groups = available_talk_groups_for_system(@system)
  end

  def available_talk_groups_for_system(system)
    case system.mode
    when "analog"
      TalkGroup.none
    when "p25"
      TalkGroup.joins(:network).where(networks: { network_type: "Digital-P25" }).order(:name)
    when "dmr"
      if system.networks.any?
        TalkGroup.where(network_id: system.network_ids).order(:name)
      else
        TalkGroup.none
      end
    else
      TalkGroup.includes(:network).order(:name)
    end
  end

  def system_talk_group_params
    params.require(:system_talk_group).permit(:talk_group_id, :timeslot)
  end
end
