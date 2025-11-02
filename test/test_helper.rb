ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Load support files
Dir[Rails.root.join("test", "support", "**", "*.rb")].each { |f| require f }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Include Factory Bot syntax methods
    include FactoryBot::Syntax::Methods

    # Add more helper methods to be used by all tests here...
  end
end

# Integration test helpers
module ActionDispatch
  class IntegrationTest
    # Helper method to simulate user login
    # Used in controller tests to authenticate a user
    def log_in_as(user)
      post login_path, params: {
        email: user.email,
        password: "password123"
      }
    end
  end
end
