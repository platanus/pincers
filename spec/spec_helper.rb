require 'pry'
require 'pincers'

FIXTURE_PATH = File.expand_path('../fixtures', __FILE__)

RSpec.configure do |config|
  config.before(:context) { Pincers.config.reset }
  config.before(:example) { Pincers.config.reset }
end