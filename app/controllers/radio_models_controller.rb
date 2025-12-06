class RadioModelsController < ApplicationController
  before_action :set_radio_model, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_view, only: [ :show ]
  before_action :authorize_edit, only: [ :edit, :update, :destroy ]

  def index
    @radio_models = RadioModel.visible_to(current_user)
                              .includes(:manufacturer)
                              .order("manufacturers.name, radio_models.name")
  end

  def show
  end

  def new
    @radio_model = RadioModel.new
    @manufacturers = Manufacturer.visible_to(current_user).order(:name)
  end

  def edit
    @manufacturers = Manufacturer.visible_to(current_user).order(:name)
  end

  def create
    @radio_model = RadioModel.new(radio_model_params)
    @radio_model.user = current_user
    @radio_model.system_record = false

    if @radio_model.save
      redirect_to radio_model_path(@radio_model), notice: "Radio model was successfully created."
    else
      @manufacturers = Manufacturer.visible_to(current_user).order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @radio_model.update(radio_model_params)
      redirect_to radio_model_path(@radio_model), notice: "Radio model was successfully updated."
    else
      @manufacturers = Manufacturer.visible_to(current_user).order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @radio_model.destroy!
    redirect_to radio_models_path, notice: "Radio model was successfully deleted."
  end

  private

  def set_radio_model
    @radio_model = RadioModel.find(params[:id])
  end

  def authorize_view
    # System records and own records are viewable
    return if @radio_model.system_record?
    return if @radio_model.user == current_user
    head :forbidden
  end

  def authorize_edit
    # Only own records are editable
    unless @radio_model.editable_by?(current_user)
      head :forbidden
    end
  end

  def radio_model_params
    params.require(:radio_model).permit(
      :manufacturer_id,
      :name,
      :max_zones,
      :max_channels_per_zone,
      :long_channel_name_length,
      :short_channel_name_length,
      :long_zone_name_length,
      :short_zone_name_length,
      supported_modes: [],
      frequency_ranges: []
    )
  end
end
