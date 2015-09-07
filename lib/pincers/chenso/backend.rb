require "pincers/nokogiri/backend"
require "pincers/support/http_navigator"
require "pincers/chenso/html_doc_request"
require "pincers/chenso/html_doc_cache"

module Pincers::Chenso
  class Backend < Pincers::Nokogiri::Backend

    attr_reader :client, :history

    def initialize(_http_client)
      super nil
      @client = _http_client
      @history = Pincers::Support::HttpNavigator.new _http_client
    end

    def document_url
      history.current_url
    end

    def navigate_to(_url)
      set_document history.push prepare_page_request _url
    end

    def navigate_forward(_steps)
      set_document history.forward _steps
    end

    def navigate_back(_steps)
      set_document history.back _steps
    end

    def refresh_document
      set_document history.refresh
    end

    def click_on_element(_element, _modifiers)
      if _element.name == 'a' and _element[:href]
        navigate_link _element[:href]
      end
    end

    def as_http_client
      @client.copy
    end

  private

    def prepare_page_request(_url)
      HtmlDocRequest.new _url, {
        headers: {
          'Accept' => 'text/html,application/xhtml+xml,application/xml',
          'Cache-Control' => 'no-cache'
        }
      }
    end

    def navigate_link(_url)
      navigate_to URI.join(document_url, _url)
    end

  end

end