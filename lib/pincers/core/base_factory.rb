module Pincers::Core

  class BaseFactory

    def self.new_context(_options)
      self.new(_options).new_context
    end

    def initialize(_options)
      @context_options = extract_context_options _options
      @backend_options = _options
    end

    def new_context
      backend = load_backend @backend_options
      ::Pincers::Core::RootContext.new backend, @context_options
    end

    def load_backend(_options)
      raise NotImplementedError
    end

  private

    def extract_context_options(_options)
      [:wait_interval, :wait_timeout, :advanced_mode].inject({}) do |opt, key|
        opt[key] = _options.delete key if _options.key? key
        opt
      end
    end

  end

end