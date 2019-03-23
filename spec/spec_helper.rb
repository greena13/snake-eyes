# frozen_string_literal: true

require 'awesome_print'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('dummy/config/environment.rb', __dir__)
require 'rspec/rails'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each(&method(:require))

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
