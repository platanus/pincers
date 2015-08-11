module Pincers::Support
  class Configuration

    class Option < Struct.new(:name, :type, :text); end

    FIELDS = [
      [:wait_timeout, 10.0],
      [:wait_interval, 0.2]
    ];

    FIELDS.each do |field|
      define_method "#{field[0]}=" do |val|
        @values[field[0]] = val
      end

      define_method "#{field[0]}" do
        @values[field[0]]
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
      @values = Hash[FIELDS]
    end
  end
end
