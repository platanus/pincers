require 'pincers/http/base_document'

module Pincers::Http
  class ResponseDocument < BaseDocument

    attr_reader :response

    def initialize(_response)
      @response = _response
    end

    def uri
      @response.uri
    end

    def content_type
      @response['Content-Type'] || 'text/plain'
    end

    def content
      @response.body
    end
  end
end