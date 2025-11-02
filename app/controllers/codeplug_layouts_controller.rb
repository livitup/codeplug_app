class CodeplugLayoutsController < ApplicationController
  before_action :set_codeplug_layout, only: [ :show, :edit, :update, :destroy ]

  def index
    @codeplug_layouts = CodeplugLayout.includes(:radio_model, :user).order(created_at: :desc)
  end

  def show
    # Display codeplug layout details
  end

  def new
    @codeplug_layout = CodeplugLayout.new
  end

  def edit
    # Edit codeplug layout form
  end

  def create
    @codeplug_layout = CodeplugLayout.new(codeplug_layout_params_with_parsed_json)
    @codeplug_layout.user = current_user if logged_in?

    if @codeplug_layout.save
      redirect_to codeplug_layout_path(@codeplug_layout), notice: "Codeplug layout was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @codeplug_layout.update(codeplug_layout_params_with_parsed_json)
      redirect_to codeplug_layout_path(@codeplug_layout), notice: "Codeplug layout was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @codeplug_layout.destroy!
    redirect_to codeplug_layouts_path, notice: "Codeplug layout was successfully deleted."
  end

  private

  def set_codeplug_layout
    @codeplug_layout = CodeplugLayout.find(params[:id])
  end

  def codeplug_layout_params
    params.require(:codeplug_layout).permit(:name, :radio_model_id, :layout_definition)
  end

  def codeplug_layout_params_with_parsed_json
    params_hash = codeplug_layout_params.to_h
    if params_hash[:layout_definition].is_a?(String)
      if params_hash[:layout_definition].blank?
        params_hash[:layout_definition] = nil
      else
        begin
          params_hash[:layout_definition] = JSON.parse(params_hash[:layout_definition])
        rescue JSON::ParserError
          # If JSON is invalid, leave it as string so validation will catch it
        end
      end
    end
    params_hash
  end
end
