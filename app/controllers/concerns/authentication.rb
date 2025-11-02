module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?
  end

  # Returns the currently logged-in user (if any)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Returns true if the user is logged in
  def logged_in?
    current_user.present?
  end

  # Logs in the given user
  def log_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  # Logs out the current user
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  # Confirms a logged-in user (before_action filter)
  def require_login
    unless logged_in?
      store_return_to_location
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end

  # Store the URL the user was trying to access
  def store_return_to_location
    # Don't store login/logout paths to avoid redirect loops
    return if request.path == login_path || request.path == logout_path

    session[:return_to] = request.fullpath
  end

  # Redirect to stored location or default
  def redirect_back_or_to(default)
    redirect_to(session.delete(:return_to) || default)
  end

  # Confirms the correct user (for authorization)
  def require_correct_user(user)
    unless current_user == user
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to root_path
    end
  end

  # Redirect if already logged in
  def redirect_if_logged_in
    redirect_to radio_models_path if logged_in?
  end
end
