require 'pincers/support/cookie_jar'
require 'pincers/core/search_context'

module Pincers::Core
  class RootContext < SearchContext

    def initialize(_backend, _options={})
      super _backend.document_root, nil
      @backend = _backend
      @options = Pincers.config.values.merge _options
    end

    def backend
      @backend
    end

    def url
      backend.document_url
    end

    def uri
      URI.parse url
    end

    def title
      backend.document_title
    end

    def source
      backend.document_source
    end

    def cookies
      @cookies ||= CookieJar.new backend
    end

    def goto(_url)
      backend.navigate_to _url
      self
    end

    def forward(_steps=1)
      backend.navigate_forward _steps
      self
    end

    def back(_steps=1)
      backend.navigate_back _steps
      self
    end

    def refresh
      backend.refresh_document _steps
      self
    end

    def default_timeout
      @options[:wait_timeout]
    end

    def default_interval
      @options[:wait_interval]
    end

  end
end
