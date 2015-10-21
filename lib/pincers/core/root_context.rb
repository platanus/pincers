require 'pincers/core/cookies'
require 'pincers/core/search_context'

module Pincers::Core
  class RootContext < SearchContext

    attr_reader :config

    def initialize(_backend, _config={})
      super nil, nil, nil
      @backend = _backend
      @config = Pincers.config.values.merge _config
    end

    def root
      self
    end

    def root?
      true
    end

    def elements
      @backend.document_root
    end

    def element
      @backend.document_root.first
    end

    def document
      @backend.document
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

    def cookies
      @cookies ||= Cookies.new backend
    end

    def goto(_urlOrOptions)
      wrap_errors do
        if _urlOrOptions.is_a? String
          _urlOrOptions = { url: _urlOrOptions }
        end

        if _urlOrOptions.key? :url
          goto_url _urlOrOptions[:url]
        elsif _urlOrOptions.key? :frame
          goto_frame _urlOrOptions[:frame]
        else
          raise ArgumentError.new "Must provide a valid target when calling 'goto'"
        end
      end
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
      wrap_errors { backend.refresh_document }
      self
    end

    def close
      wrap_errors { backend.close_document }
      self
    end

    def default_timeout
      @config[:wait_timeout]
    end

    def default_interval
      @config[:wait_interval]
    end

    def advanced_mode?
      @config[:advanced_mode]
    end

    def download(_url)
      as_http_client.get(_url).document
    end

    def as_http_client(&_block)
      http_client = backend.as_http_client
      unless _block.nil?
        r = _block.call http_client
        # sync_with http_client # TODO :copy cookies and maybe url?
        r
      else
        http_client
      end
    end

  private

    def wrap_siblings(_elements)
      # root node siblings behave like childs
      SearchContext.new _elements, self, nil
    end

    def goto_url(_url)
      _url = "http://#{_url}" unless /^(https?|file|ftp):\/\// === _url
      backend.navigate_to _url
    end

    def goto_frame(_frame)
      case _frame
      when :top
        backend.switch_to_top_frame
      when :parent
        backend.switch_to_parent_frame
      when String
        backend.switch_to_frame search(_frame).element!
      when SearchContext
        backend.switch_to_frame _frame.element!
      else
        raise ArgumentError.new "Invalid :frame option #{_frame.inspect}"
      end
    end

  end
end
