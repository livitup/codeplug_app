class ZonesController < ApplicationController
  # Only run these for nested routes (when codeplug_id is present)
  before_action :set_codeplug, if: :nested_route?
  before_action :authorize_codeplug, if: :nested_route?
  before_action :set_zone, only: [ :show, :edit, :update, :destroy, :update_positions ]
  before_action :authorize_zone, only: [ :show, :edit, :update, :destroy ], unless: :nested_route?

  def index
    if nested_route?
      # Nested route: show zones for specific codeplug
      @zones = @codeplug.zones.order(:name)
    else
      # Standalone route: show zones available to current user
      @zones = Zone.available_to_user(current_user).order(:name)
    end
  end

  def show
    if nested_route?
      # Nested route: Get channels for codeplug
      channel_ids_in_zone = @zone.channel_zones.pluck(:channel_id)

      @available_channels = @codeplug.channels
                                      .where.not(id: channel_ids_in_zone)
                                      .order(:long_name)
    else
      # Standalone route: Show zone systems (placeholder for future functionality)
      @zone_systems = @zone.zone_systems.includes(:system).order(:position)
    end
  end

  def new
    if nested_route?
      @zone = @codeplug.zones.new
    else
      @zone = Zone.new
    end
  end

  def edit
    # Edit zone form
  end

  def create
    if nested_route?
      @zone = @codeplug.zones.new(zone_params)
      @zone.user = current_user

      if @zone.save
        redirect_to codeplug_zone_path(@codeplug, @zone), notice: "Zone was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    else
      @zone = Zone.new(zone_params)
      @zone.user = current_user

      if @zone.save
        redirect_to zone_path(@zone), notice: "Zone was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    if @zone.update(zone_params)
      if nested_route?
        redirect_to codeplug_zone_path(@codeplug, @zone), notice: "Zone was successfully updated."
      else
        redirect_to zone_path(@zone), notice: "Zone was successfully updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @zone.destroy!
    if nested_route?
      redirect_to codeplug_zones_path(@codeplug), notice: "Zone was successfully deleted."
    else
      redirect_to zones_path, notice: "Zone was successfully deleted."
    end
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
    if nested_route?
      @zone = @codeplug.zones.find(params[:id])
    else
      @zone = Zone.find(params[:id])
    end
  end

  def authorize_codeplug
    unless @codeplug.user == current_user
      redirect_to codeplugs_path, alert: "You don't have permission to access this codeplug."
    end
  end

  def authorize_zone
    # For standalone routes, check if user can view/edit the zone
    action = action_name.to_sym

    if [ :show ].include?(action)
      unless @zone.viewable_by?(current_user)
        head :forbidden
      end
    elsif [ :edit, :update, :destroy ].include?(action)
      unless @zone.editable_by?(current_user)
        head :forbidden
      end
    end
  end

  def nested_route?
    params[:codeplug_id].present?
  end

  def zone_params
    params.require(:zone).permit(:name, :long_name, :short_name, :public)
  end
end
