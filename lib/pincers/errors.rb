module Pincers

  class Error < StandardError; end

  class ConfigurationError < Error; end

  class MissingFeatureError < Error

    attr_accessor :feature

    def initialize(_feature)
      @feature = _feature
      super "This backend does not provide '#{_feature}'"
    end

  end

  class BackendError < Error

    def initialize(_backend, _msg)
      # backend errors should be configurable to get source from backend
      super _msg
    end

  end

  class EmptySetError < BackendError

    def initialize(_node)
      super _node.backend, "This set is empty"
    end

  end

  class ConditionTimeoutError < BackendError

    def initialize(_node, _condition)
      super _node.backend, "Timed out waiting element to be #{_condition}"
    end

  end





  class

  class BinaryMissingError < ConfigurationError

    attr_accessor :binary
    attr_accessor :path

    def initialize(_binary, _path)
      @binary = _binary
      @path = _path
      super "Could not find a suitable version of #{@binary}"
    end

  end

  class def  < Error; end

  class ArgumentError < Error; end

  class ResourceNotFoundError < Crabfarm::Error; end

  class ApiError < Error
    def code; 500 end
    def to_json; {} end
  end

  class StillWorkingError < ApiError
    def code; 409 end
  end

  class TimeoutError < ApiError
    def code; 408 end
  end

  class CrawlerBaseError < ApiError
    def initialize(_msg, _trace)
      @exc = _msg
      @trace = _trace
    end

    def to_json
      {
        exception: @exc,
        backtrace: @trace
      }.to_json
    end
  end

  class CrawlerError < CrawlerBaseError
    def initialize(_exc)
      super _exc.to_s, _exc.backtrace
    end
  end

end
