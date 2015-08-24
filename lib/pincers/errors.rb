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

  class EmptySetError < ContextError

    def initialize(_context)
      super _context, "This set is empty"
    end

  end

  class ConditionTimeoutError < ContextError

    def initialize(_context, _condition)
      super _context, "Timed out waiting element to be #{_condition}"
    end

  end

  class BackendError < ContextError

    attr_reader :document
    attr_reader :original

    def initialize(_context, _exc)
      super _context, "Backend error: #{_exc.message}"
      @document = _context.document
      @original = _exc
    end

    # IDEA: join backtraces?

  end

end
