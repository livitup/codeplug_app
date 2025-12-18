class ZonesController < ApplicationController
  before_action :set_zone, only: [ :show, :edit, :update, :destroy, :update_positions ]
  before_action :authorize_zone_view, only: [ :show ]
  before_action :authorize_zone_edit, only: [ :edit, :update, :destroy, :update_positions ]

  def index
    @zones = Zone.available_to_user(current_user).order(:name)
  end

  def show
    @zone_systems = @zone.zone_systems.includes(:system).order(:position)
  end

  def new
    @zone = Zone.new
  end

  def edit
  end

  def create
    @zone = Zone.new(zone_params)
    @zone.user = current_user

    if @zone.save
      redirect_to zone_path(@zone), notice: "Zone was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @zone.update(zone_params)
      redirect_to zone_path(@zone), notice: "Zone was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @zone.destroy!
    redirect_to zones_path, notice: "Zone was successfully deleted."
  end

  def update_positions
    positions_params = params.permit(positions: [ :id, :position ])

    ActiveRecord::Base.transaction do
      # First pass: Set temporary positions to avoid uniqueness conflicts
      positions_params[:positions].each_with_index do |position_data, index|
        zone_system = @zone.zone_systems.find(position_data[:id])
        zone_system.update_column(:position, 1000 + index)
      end

      # Second pass: Set actual positions
      positions_params[:positions].each do |position_data|
        zone_system = @zone.zone_systems.find(position_data[:id])
        zone_system.update!(position: position_data[:position])
      end
    end

    head :ok
  end

  private

  def set_zone
    @zone = Zone.find(params[:id])
  end

  def authorize_zone_view
    unless @zone.viewable_by?(current_user)
      head :forbidden
    end
  end

  def authorize_zone_edit
    unless @zone.editable_by?(current_user)
      head :forbidden
    end
  end

  def zone_params
    params.require(:zone).permit(:name, :long_name, :short_name, :public)
  end
end
