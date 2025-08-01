DEFAULT_PASSWORD = "password123"

module AuthHelper
  def sign_in(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def sign_out
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
