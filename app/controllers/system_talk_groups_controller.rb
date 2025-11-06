class SystemTalkGroupsController < ApplicationController
  before_action :set_system

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

  def system_talk_group_params
    params.require(:system_talk_group).permit(:talk_group_id, :timeslot)
  end
end
