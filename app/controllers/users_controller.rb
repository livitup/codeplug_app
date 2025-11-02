class UsersController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]
  before_action :set_user, only: [ :show, :edit, :update ]
  before_action :require_correct_user_access, only: [ :edit, :update ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      log_in(@user)
      flash[:notice] = "Account created successfully!"
      redirect_to root_path
    else
      flash.now[:alert] = "There was an error creating your account. Please check the form for errors."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Display user profile
  end

  def edit
    # Edit user profile form
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "Profile updated successfully!"
      redirect_to user_path(@user)
    else
      flash.now[:alert] = "There was an error updating your profile. Please check the form for errors."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_correct_user_access
    require_correct_user(@user)
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :callsign, :default_power_level, :measurement_preference)
  end
end
