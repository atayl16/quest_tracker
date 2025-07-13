class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Temporary method until we add Devise
  def current_user
    nil
  end
  helper_method :current_user
end
