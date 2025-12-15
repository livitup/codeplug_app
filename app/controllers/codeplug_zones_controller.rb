class CodeplugZonesController < ApplicationController
  before_action :set_codeplug
  before_action :authorize_codeplug_owner

  def create
    zone = Zone.find(params[:codeplug_zone][:zone_id])

    # Validate zone is accessible to user
    unless zone.viewable_by?(current_user)
      redirect_to codeplug_path(@codeplug), alert: "You cannot add that zone to your codeplug.", status: :unprocessable_entity
      return
    end

    @codeplug_zone = @codeplug.codeplug_zones.new(codeplug_zone_params)

    # Auto-assign next available position
    max_position = @codeplug.codeplug_zones.maximum(:position) || 0
    @codeplug_zone.position = max_position + 1

    if @codeplug_zone.save
      redirect_to codeplug_path(@codeplug), notice: "Zone was successfully added to codeplug."
    else
      redirect_to codeplug_path(@codeplug), alert: @codeplug_zone.errors.full_messages.join(", "), status: :unprocessable_entity
    end
  end

  def destroy
    @codeplug_zone = @codeplug.codeplug_zones.find(params[:id])
    position = @codeplug_zone.position

    @codeplug_zone.destroy!

    # Reorder remaining positions
    @codeplug.codeplug_zones.unscoped.where(codeplug: @codeplug).where("position > ?", position).update_all("position = position - 1")

    redirect_to codeplug_path(@codeplug), notice: "Zone was successfully removed from codeplug."
  end

  def update_positions
    positions_params = params.permit(positions: [ :id, :position ])

    ActiveRecord::Base.transaction do
      # First pass: Set temporary positions to avoid uniqueness conflicts
      positions_params[:positions].each_with_index do |position_data, index|
        codeplug_zone = @codeplug.codeplug_zones.unscoped.find(position_data[:id])
        codeplug_zone.update_column(:position, 1000 + index)
      end

      # Second pass: Set actual positions
      positions_params[:positions].each do |position_data|
        codeplug_zone = @codeplug.codeplug_zones.unscoped.find(position_data[:id])
        codeplug_zone.update!(position: position_data[:position])
      end
    end

    head :ok
  end

  private

  def set_codeplug
    @codeplug = Codeplug.find(params[:codeplug_id])
  end

  def authorize_codeplug_owner
    unless @codeplug.user == current_user
      head :forbidden
    end
  end

  def codeplug_zone_params
    params.require(:codeplug_zone).permit(:zone_id)
  end
end
