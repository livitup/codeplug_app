class ZoneSystemsController < ApplicationController
  before_action :set_zone
  before_action :authorize_zone_owner

  def create
    @zone_system = @zone.zone_systems.new(zone_system_params)

    # Auto-assign next available position
    max_position = @zone.zone_systems.maximum(:position) || 0
    @zone_system.position = max_position + 1

    if @zone_system.save
      redirect_to zone_path(@zone), notice: "System was successfully added to zone."
    else
      redirect_to zone_path(@zone), alert: @zone_system.errors.full_messages.join(", "), status: :unprocessable_entity
    end
  end

  def destroy
    @zone_system = @zone.zone_systems.find(params[:id])
    position = @zone_system.position

    @zone_system.destroy!

    # Reorder remaining positions
    @zone.zone_systems.where("position > ?", position).update_all("position = position - 1")

    redirect_to zone_path(@zone), notice: "System was successfully removed from zone."
  end

  private

  def set_zone
    @zone = Zone.find(params[:zone_id])
  end

  def authorize_zone_owner
    unless @zone.editable_by?(current_user)
      head :forbidden
    end
  end

  def zone_system_params
    params.require(:zone_system).permit(:system_id)
  end
end
