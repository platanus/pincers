module Pincers::Http
  class RequestError < StandardError
    extend Forwardable

    def_delegators :@response, :code, :body

    attr_reader :response

    def initialize(_response)
      @response = _response
      super _response.message
    end
  end

  class MaximumRedirectsError < StandardError
    def initialize
      super 'Redirection loop detected!'
    end
  end
end