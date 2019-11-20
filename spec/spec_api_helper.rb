require 'spec_helper'

gem_dir = Gem::Specification.find_by_name("spree_api").gem_dir
Dir["#{gem_dir}/spec/support/**/*.rb"].each do |f|
  require f
end

Dir["#{gem_dir}/lib/spree/api/testing_support/**/*.rb"].each do |f|
  require f
end

RSpec.configure do |config|
  config.include Spree::Api::TestingSupport::Helpers, type: :controller
  config.include Spree::Api::TestingSupport::Helpers, type: :request
  config.extend Spree::Api::TestingSupport::Setup, type: :controller
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
    with.library :action_controller
  end
end