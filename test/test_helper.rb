ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "action_mailbox/test_case"

# require anything in test/support
Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |f| require f }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def turbo_stream_headers
      { Accept: "text/vnd.turbo-stream.html, text/html, application/xhtml+xml" }
    end
  end
end

# ensures url_for works in test
ActionView::TestCase::TestController.instance_eval do
  helper Rails.application.routes.url_helpers
end

ActionView::TestCase::TestController.class_eval do
  def _routes
    Rails.application.routes
  end
end
