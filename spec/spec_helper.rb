require 'pry'
require 'pincers'

Dir[File.expand_path("../macros/*.rb", __FILE__)].each { |f| require f }

FIXTURE_PATH = File.expand_path('../fixtures', __FILE__)

RSpec.configure do |config|
  config.before(:context) { Pincers.config.reset }
  config.before(:example) { Pincers.config.reset }
end

include Macros::Read