module Pincers::Http
  class Response

    attr_reader :uri, :response

    def initialize(_uri, _response)
      @response = _response
      @uri = _uri
    end

    def code
      @response.code
    end

    def message
      @response.message
    end

    def content_type
      @response['Content-Type'] || 'text/plain'
    end

    def content
      @response.body
    end
  end
end