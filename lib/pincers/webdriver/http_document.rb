require 'pincers/http/utils'

module Pincers::Webdriver
  class HttpDocument

    def initialize(_backend)
      @backend = _backend
    end

    def uri
      Pincers::Http::Utils.parse_uri @backend.document_url
    end

    def content_type
      'text/html'
    end

    def content
      @backend
    end

  end
end