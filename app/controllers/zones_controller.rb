class ZonesController < ApplicationController
  before_action :set_codeplug
  before_action :authorize_codeplug
  before_action :set_zone, only: [ :show, :edit, :update, :destroy, :update_positions ]

  def index
    @zones = @codeplug.zones.order(:name)
  end

  def show
    # Get channels already in this zone
    channel_ids_in_zone = @zone.channel_zones.pluck(:channel_id)

    # Get available channels (channels in codeplug that aren't already in this zone)
    @available_channels = @codeplug.channels
                                    .where.not(id: channel_ids_in_zone)
                                    .order(:long_name)
  end

  def new
    @zone = @codeplug.zones.new
  end

  def edit
    # Edit zone form
  end

  def create
    @zone = @codeplug.zones.new(zone_params)

    if @zone.save
      redirect_to codeplug_zone_path(@codeplug, @zone), notice: "Zone was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @zone.update(zone_params)
      redirect_to codeplug_zone_path(@codeplug, @zone), notice: "Zone was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @zone.destroy!
    redirect_to codeplug_zones_path(@codeplug), notice: "Zone was successfully deleted."
  end

  def update_positions
    positions_params = params.permit(positions: [ :id, :position ])

    ActiveRecord::Base.transaction do
      # First pass: Set temporary positions to avoid uniqueness conflicts
      positions_params[:positions].each_with_index do |position_data, index|
        channel_zone = @zone.channel_zones.find(position_data[:id])
        channel_zone.update_column(:position, 1000 + index)
      end

      # Second pass: Set actual positions
      positions_params[:positions].each do |position_data|
        channel_zone = @zone.channel_zones.find(position_data[:id])
        channel_zone.update!(position: position_data[:position])
      end
    end

    head :ok
  end

  private

  def set_codeplug
    @codeplug = Codeplug.find(params[:codeplug_id])
  end

  def set_zone
    @zone = @codeplug.zones.find(params[:id])
  end

  def authorize_codeplug
    unless @codeplug.user == current_user
      redirect_to codeplugs_path, alert: "You don't have permission to access this codeplug."
    end
  end

  def zone_params
    params.require(:zone).permit(:name, :long_name, :short_name)
  end
end
