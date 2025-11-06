class ZonesController < ApplicationController
  before_action :set_codeplug
  before_action :authorize_codeplug
  before_action :set_zone, only: [ :show, :edit, :update, :destroy ]

  def index
    @zones = @codeplug.zones.order(:name)
  end

  def show
    # Display zone details
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
