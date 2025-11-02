class SessionsController < ApplicationController
  include Authentication

  before_action :redirect_if_logged_in, only: [ :new, :create ]

  def new
    # Render login form
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      log_in(user)
      flash[:notice] = "Logged in successfully!"
      redirect_to root_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    flash[:notice] = "Logged out successfully!"
    redirect_to root_path
  end
end
