module Pincers::Support
  class Configuration

    class Option < Struct.new(:name, :type, :text); end

    OPTIONS = [
      [:wait_timeout, 10.0],
      [:wait_interval, 0.2]
    ];

    OPTIONS.each do |var|
      define_method "#{var.name}=" do |val|
        @values[var.name] = val
      end

      define_method "#{var.name}" do
        @values[var.name]
      end
    end

    attr_reader :values

    def initialize
      reset
    end

    def set(_options)
      @values.merge! _options
    end

    def reset
      @values = Hash[OPTIONS]
    end
  end
end
