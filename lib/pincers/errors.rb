module Pincers

  class Error < StandardError; end

  class ConfigurationError < Error; end

  class MissingFeatureError < Error

    attr_reader :feature

    def initialize(_feature)
      @feature = _feature
      super "This backend does not provide '#{_feature}'"
    end

  end

  class ContextError < Error

    attr_reader :context

    def initialize(_context, _msg)
      super _msg
      @context = _context
    end

  end

  class FrozenSetError < ContextError

    def initialize(_context)
      super _context, "The set is frozen and cant be modified"
    end

  end

  class NavigationError < ContextError; end

  class ConditionTimeoutError < NavigationError

    def initialize(_context, _condition)
      message = if _condition
        "Timed out waiting element to be #{_condition}"
      else
        "Timed out waiting for element match custom condition"
      end

      super _context, message
    end

  end

  class EmptySetError < NavigationError

    def initialize(_context)
      super _context, "This set is empty"
    end

  end

  class BackendError < NavigationError

    attr_reader :document
    attr_reader :original

    def initialize(_context, _exc)
      super _context, "#{_exc.class.to_s}: #{_exc.message}"
      @document = _context.root.document
      @original = _exc
    end

    def backtrace
      # IDEA: join backtraces?
      @original.backtrace
    end

  end

end
