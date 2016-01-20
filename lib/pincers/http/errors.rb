module Pincers::Http
  class RequestError < StandardError
    extend Forwardable

    def_delegators :@response, :code, :uri, :content

    attr_reader :response

    def initialize(_response)
      @response = _response
      super _response.message
    end
  end

  class EncodingNotSupported < StandardError
    def initialize(_encoding)
      super "#{_encoding} is not supported by this operation"
    end
  end

  class MaximumRedirectsError < StandardError
    def initialize
      super 'Redirection loop detected!'
    end
  end
end