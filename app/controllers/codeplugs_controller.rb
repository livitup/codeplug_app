class CodeplugsController < ApplicationController
  before_action :set_codeplug, only: [ :show, :edit, :update, :destroy, :generate_channels ]
  before_action :authorize_codeplug, only: [ :edit, :update, :destroy, :generate_channels ]
  before_action :authorize_view, only: [ :show ]

  def index
    @codeplugs = current_user.codeplugs.order(:name)
  end

  def show
    # Display codeplug details
  end

  def new
    @codeplug = current_user.codeplugs.new
  end

  def edit
    # Edit codeplug form
  end

  def create
    @codeplug = current_user.codeplugs.new(codeplug_params)

    if @codeplug.save
      redirect_to codeplug_path(@codeplug), notice: "Codeplug was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @codeplug.update(codeplug_params)
      redirect_to codeplug_path(@codeplug), notice: "Codeplug was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @codeplug.destroy!
    redirect_to codeplugs_path, notice: "Codeplug was successfully deleted."
  end

  def generate_channels
    # Check if channels already exist and confirmation is required
    if @codeplug.channels.any? && params[:confirm_regenerate] != "true"
      redirect_to codeplug_path(@codeplug), alert: "This codeplug already has #{@codeplug.channels.count} channel(s). Please confirm regeneration to replace them."
      return
    end

    regenerate = @codeplug.channels.any?
    generator = ChannelGenerator.new(@codeplug)
    result = generator.generate_channels(regenerate: regenerate)

    if result[:skipped]
      redirect_to codeplug_path(@codeplug), alert: "Channel generation was skipped."
    else
      message = "Successfully generated #{result[:channels_created]} channel(s) from #{result[:zones_processed]} zone(s)."
      redirect_to codeplug_path(@codeplug), notice: message
    end
  end

  private

  def set_codeplug
    @codeplug = Codeplug.includes(:zones, channels: :system).find(params[:id])
  end

  def authorize_codeplug
    unless @codeplug.user == current_user
      redirect_to codeplugs_path, alert: "You don't have permission to access this codeplug."
    end
  end

  def authorize_view
    unless @codeplug.user == current_user || @codeplug.public?
      redirect_to codeplugs_path, alert: "You don't have permission to access this codeplug."
    end
  end

  def codeplug_params
    params.require(:codeplug).permit(:name, :description, :public)
  end
end
