require "nokogiri"
require "forwardable"
require "pincers/version"
require "pincers/errors"
require 'pincers/core/root_context'
require "pincers/factory"
require "pincers/support/configuration"

module Pincers
  extend Factory

  @@config = Support::Configuration.new

  def self.config
    @@config
  end

  def self.configure
    yield @@config
  end

end
