require 'rspec_json_matchers'

RSpec.configure do |config|
  config.include RSpecJsonMatchers
end

Dir[File.dirname(__FILE__) + '/json_matchers/**/*.rb'].each { |f| require f }
