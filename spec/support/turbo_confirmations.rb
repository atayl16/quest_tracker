# Helper to handle Turbo confirmations in system tests
# Turbo uses custom modals instead of native browser confirm dialogs
module TurboConfirmations
  def accept_turbo_confirm
    # Execute JavaScript to accept any Turbo confirmation
    page.execute_script(<<~JS)
      document.addEventListener('turbo:before-fetch-request', function(event) {
        if (event.detail.fetchOptions.headers['Turbo-Confirm']) {
          event.preventDefault();
          // Simulate accepting the confirmation
          event.detail.resume();
        }
      });
    JS
  end

  def dismiss_turbo_confirm
    # Execute JavaScript to dismiss any Turbo confirmation
    page.execute_script(<<~JS)
      document.addEventListener('turbo:before-fetch-request', function(event) {
        if (event.detail.fetchOptions.headers['Turbo-Confirm']) {
          event.preventDefault();
          // Simulate dismissing the confirmation
          event.detail.cancel();
        }
      });
    JS
  end
end

RSpec.configure do |config|
  config.include TurboConfirmations, type: :system
end
