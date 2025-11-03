class CodeplugsController < ApplicationController
  before_action :set_codeplug, only: [ :show, :edit, :update, :destroy ]

  def index
    @codeplugs = Codeplug.order(:name)
  end

  def show
    # Display codeplug details
  end

  def new
    @codeplug = Codeplug.new
  end

  def edit
    # Edit codeplug form
  end

  def create
    @codeplug = Codeplug.new(codeplug_params)

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

  private

  def set_codeplug
    @codeplug = Codeplug.find(params[:id])
  end

  def codeplug_params
    params.require(:codeplug).permit(:name, :description, :public, :user_id)
  end
end
