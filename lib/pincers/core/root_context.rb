require 'pincers/support/cookie_jar'
require 'pincers/core/search_context'

module Pincers::Core
  class RootContext < SearchContext

    attr_reader :config

    def initialize(_backend, _config={})
      super _backend.document_root, nil
      @backend = _backend
      @config = Pincers.config.values.merge _config
    end

    def root
      self
    end

    def backend
      @backend
    end

    def url
      wrap_errors { backend.document_url }
    end

    def uri
      URI.parse url
    end

    def title
      wrap_errors { backend.document_title }
    end

    def source
      wrap_errors { backend.document_source }
    end

    def cookies
      @cookies ||= CookieJar.new backend
    end

    def goto(_url)
      wrap_errors { backend.navigate_to _url }
      self
    end

    def forward(_steps=1)
      wrap_errors { backend.navigate_forward _steps }
      self
    end

    def back(_steps=1)
      wrap_errors { backend.navigate_back _steps }
      self
    end

    def refresh
      wrap_errors { backend.refresh_document _steps }
      self
    end

    def default_timeout
      @config[:wait_timeout]
    end

    def default_interval
      @config[:wait_interval]
    end

  end
end
