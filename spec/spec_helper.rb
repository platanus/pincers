require 'pry'
require 'pincers'
require 'webmock/rspec'

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |f| require f }
Dir[File.expand_path("../macros/*.rb", __FILE__)].each { |f| require f }

FIXTURE_PATH = File.expand_path('../fixtures', __FILE__)
SERVER_PORT = 9292

RSpec.configure do |config|
  config.before(:context) { Pincers.config.reset }
  config.before(:example) { Pincers.config.reset }
end

# Include all files under spec/support
Dir["./spec/support/**/*.rb"].each {|f| require f}

# Start a local rack server to serve up test pages.
@server_thread = Thread.start do
  Rack::Handler::Thin.run Pincers::Test::Server.new, :Port => SERVER_PORT
end

sleep(1) # wait a sec for the server to be booted

WebMock.disable_net_connect!(allow_localhost: true)

include Macros