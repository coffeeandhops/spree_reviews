require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'

begin
  require File.expand_path('../dummy/config/environment', __FILE__)
rescue LoadError
  puts 'Could not load dummy application. Please ensure you have run `bundle exec rake test_app`'
  exit
end

require 'jsonapi/rspec'
require 'rspec/rails'
require 'ffaker'
require 'pry'
require 'shoulda-matchers'
require 'rails-controller-testing'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/preferences'

gem_dir = Gem::Specification.find_by_name("spree_api").gem_dir
# Dir["#{gem_dir}/spec/support/**/*.rb"].each do |f|
#   require f
# end

# Dir["#{gem_dir}/lib/spree/api/testing_support/**/*.rb"].each do |f|
#   require f
# end


RSpec.configure do |config|
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Spree::Core::Engine.routes.url_helpers
  config.include Rails::Controller::Testing::TestProcess, type: :controller
  config.include Rails::Controller::Testing::Integration, type: :controller
  config.include Rails::Controller::Testing::TemplateAssertions, type: :controller
  # config.include Devise::Test::ControllerHelpers, type: :controller
  config.include JSONAPI::RSpec
  # config.include Spree::Api::TestingSupport::Helpers, type: :controller
  # config.include Spree::Api::TestingSupport::Helpers, type: :request
  # config.extend Spree::Api::TestingSupport::Setup, type: :controller

  config.fail_fast = false
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.raise_errors_for_deprecations!
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end

# Shoulda::Matchers.configure do |config|
#   config.integrate do |with|
#     with.test_framework :rspec
#     with.library :active_record
#     with.library :active_model
#     with.library :action_controller
#   end
# end

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |file| require file }
