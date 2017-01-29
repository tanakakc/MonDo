class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :no_cache_for_safari

  def no_cache_for_safari
    user_agent = UserAgent.parse(request.user_agent)
    if user_agent.browser == "Safari"
      response.headers["Cache-Control"] = "no-cache"
    end
  end

  end
