class NetworksController < ApplicationController
  before_action :set_network, only: [ :show, :edit, :update, :destroy ]

  def index
    @networks = Network.order(:name)
  end

  def show
    # Display network details
  end

  def new
    @network = Network.new
  end

  def edit
    # Edit network form
  end

  def create
    @network = Network.new(network_params)

    if @network.save
      redirect_to network_path(@network), notice: "Network was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @network.update(network_params)
      redirect_to network_path(@network), notice: "Network was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @network.destroy!
    redirect_to networks_path, notice: "Network was successfully deleted."
  end

  private

  def set_network
    @network = Network.find(params[:id])
  end

  def network_params
    params.require(:network).permit(:name, :description, :website, :network_type)
  end
end
