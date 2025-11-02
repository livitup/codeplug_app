class TalkGroupsController < ApplicationController
  before_action :set_talk_group, only: [ :show, :edit, :update, :destroy ]

  def index
    if params[:network_id].present?
      @talk_groups = TalkGroup.where(network_id: params[:network_id]).order(:talkgroup_number)
    else
      @talk_groups = TalkGroup.includes(:network).order(:talkgroup_number)
    end
  end

  def show
    # Display talk group details
  end

  def new
    @talk_group = TalkGroup.new
    @networks = Network.order(:name)
  end

  def edit
    @networks = Network.order(:name)
  end

  def create
    @talk_group = TalkGroup.new(talk_group_params)

    if @talk_group.save
      redirect_to talk_group_path(@talk_group), notice: "TalkGroup was successfully created."
    else
      @networks = Network.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @talk_group.update(talk_group_params)
      redirect_to talk_group_path(@talk_group), notice: "TalkGroup was successfully updated."
    else
      @networks = Network.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @talk_group.destroy!
    redirect_to talk_groups_path, notice: "TalkGroup was successfully deleted."
  end

  private

  def set_talk_group
    @talk_group = TalkGroup.find(params[:id])
  end

  def talk_group_params
    params.require(:talk_group).permit(:network_id, :name, :talkgroup_number, :description)
  end
end
