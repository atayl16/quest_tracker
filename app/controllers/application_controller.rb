class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Session-based authentication
  def current_user
    if session[:user_id]
      if Rails.env.production?
        # In production, use localStorage service
        @current_user ||= OpenStruct.new(
          id: session[:user_id],
          username: 'demo',
          email: 'demo@example.com'
        )
      else
        # In development, use database
        @current_user ||= User.find_by(id: session[:user_id])
      end
    end
  end
  helper_method :current_user

  def signed_in?
    !!current_user
  end
  helper_method :signed_in?

  def authenticate_user!
    redirect_to signin_path unless signed_in?
  end
end
