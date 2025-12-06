class ManufacturersController < ApplicationController
  before_action :set_manufacturer, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_view, only: [ :show ]
  before_action :authorize_edit, only: [ :edit, :update, :destroy ]

  def index
    @manufacturers = Manufacturer.visible_to(current_user).order(:name)
  end

  def show
    # Display manufacturer details
  end

  def new
    @manufacturer = Manufacturer.new
  end

  def edit
    # Edit manufacturer form
  end

  def create
    @manufacturer = Manufacturer.new(manufacturer_params)
    @manufacturer.user = current_user
    @manufacturer.system_record = false

    if @manufacturer.save
      redirect_to manufacturer_path(@manufacturer), notice: "Manufacturer was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @manufacturer.update(manufacturer_params)
      redirect_to manufacturer_path(@manufacturer), notice: "Manufacturer was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @manufacturer.destroy!
    redirect_to manufacturers_path, notice: "Manufacturer was successfully deleted."
  end

  private

  def set_manufacturer
    @manufacturer = Manufacturer.find(params[:id])
  end

  def authorize_view
    # System records and own records are viewable
    return if @manufacturer.system_record?
    return if @manufacturer.user == current_user
    head :forbidden
  end

  def authorize_edit
    # Only own records are editable
    unless @manufacturer.editable_by?(current_user)
      head :forbidden
    end
  end

  def manufacturer_params
    params.require(:manufacturer).permit(:name)
  end
end
