class SystemsController < ApplicationController
  before_action :set_system, only: [ :show, :edit, :update, :destroy ]

  def index
    @systems = System.includes(:mode_detail).order(:name)
  end

  def show
    # Display system details
  end

  def new
    @system = System.new
  end

  def edit
    # Edit system form
  end

  def create
    @system = System.new(system_params)

    if @system.save
      redirect_to system_path(@system), notice: "System was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @system.update(system_params)
      redirect_to system_path(@system), notice: "System was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @system.destroy!
    redirect_to systems_path, notice: "System was successfully deleted."
  end

  private

  def set_system
    @system = System.includes(:mode_detail).find(params[:id])
  end

  def system_params
    params.require(:system).permit(
      :name, :mode, :tx_frequency, :rx_frequency, :bandwidth,
      :supports_tx_tone, :supports_rx_tone, :tx_tone_value, :rx_tone_value,
      :city, :state, :county, :latitude, :longitude,
      :mode_detail_id, :mode_detail_type
    )
  end
end
