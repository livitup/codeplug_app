class PagesController < ApplicationController
  skip_before_action :require_login

  def home
    # Home/landing page
  end

  def help
    # Help/documentation page
  end

  def about
    # About page
  end
end
