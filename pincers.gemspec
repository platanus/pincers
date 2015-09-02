# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pincers/version'

Gem::Specification.new do |spec|
  spec.name          = "pincers"
  spec.description   = "Web automation DSL on top of webdriver and nokogiri"
  spec.version       = Pincers::VERSION
  spec.authors       = ["Ignacio Baixas"]
  spec.email         = ["ignacio@platan.us"]
  spec.summary       = "Web automation framework with multiple backend support"
  spec.homepage      = "https://github.com/platanus/pincers"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", '~> 1.6'
  spec.add_dependency "selenium-webdriver", "~> 2.45"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", '~> 0'
  spec.add_development_dependency "rspec", '~> 0'
  spec.add_development_dependency "rspec-nc", '~> 0'
  spec.add_development_dependency "guard", '~> 0'
  spec.add_development_dependency "guard-rspec", '~> 0'
  spec.add_development_dependency "terminal-notifier-guard", '~> 1.6'
  spec.add_development_dependency "pry", '~> 0'
  spec.add_development_dependency "pry-remote", '~> 0'
  spec.add_development_dependency "pry-nav", '~> 0'
  spec.add_development_dependency "rack", '~> 0'
  spec.add_development_dependency "thin", '~> 0'
end
