class PagesController < ApplicationController
  skip_before_action :require_login

  def home
    if logged_in?
      setup_dashboard_data
      render :dashboard
    end
    # Otherwise render default home view (landing page)
  end

  private

  def setup_dashboard_data
    @codeplugs_count = current_user.codeplugs.count
    @zones_count = current_user.zones.count
    @public_zones_count = Zone.publicly_visible.where.not(user: current_user).count
    @recent_codeplugs = current_user.codeplugs.order(created_at: :desc).limit(5)
    @recent_zones = current_user.zones.order(created_at: :desc).limit(5)
  end

  def help
    # Help/documentation page
  end

  def about
    # About page
  end
end
