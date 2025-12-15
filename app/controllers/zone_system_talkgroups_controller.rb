class ZoneSystemTalkgroupsController < ApplicationController
  before_action :set_zone
  before_action :set_zone_system
  before_action :authorize_zone_owner

  def create
    @zone_system_talkgroup = @zone_system.zone_system_talkgroups.new(zone_system_talkgroup_params)

    if @zone_system_talkgroup.save
      redirect_to zone_path(@zone), notice: "Talkgroup was successfully added."
    else
      redirect_to zone_path(@zone), alert: @zone_system_talkgroup.errors.full_messages.join(", "), status: :unprocessable_entity
    end
  end

  def destroy
    @zone_system_talkgroup = @zone_system.zone_system_talkgroups.find(params[:id])
    @zone_system_talkgroup.destroy!

    redirect_to zone_path(@zone), notice: "Talkgroup was successfully removed."
  end

  private

  def set_zone
    @zone = Zone.find(params[:zone_id])
  end

  def set_zone_system
    @zone_system = @zone.zone_systems.find(params[:zone_system_id])
  end

  def authorize_zone_owner
    unless @zone.editable_by?(current_user)
      head :forbidden
    end
  end

  def zone_system_talkgroup_params
    params.require(:zone_system_talk_group).permit(:system_talk_group_id)
  end
end
