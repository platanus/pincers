require 'pincers/http/utils'
require 'pincers/chenso/browsing_state'

module Pincers::Chenso
  class HtmlPageRequest

    DEFAULT_HEADERS = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml',
      'Cache-Control' => 'no-cache'
    }

    def initialize(_url, _method=:get, _data=nil, _encoding=nil)
      @url =  _url
      @method = _method
      @data = _data
      @encoding = _encoding
    end

    def fix_uri(_current_state)
      @uri = Pincers::Http::Utils.parse_uri @url
      if _current_state
        base = _current_state.document.at_css 'base'
        base = if base and base[:href]
          URI.join _current_state.uri, base[:href]
        else
          _current_state.uri
        end

        @uri = URI.join(base, @uri)
      elsif @uri.relative?
        raise ArgumentError, 'Absolute uri required'
      end
    end

    def execute(_client)
      response = begin
        _client.send(@method, @uri) do |request|
          request.headers.merge DEFAULT_HEADERS
          request.set_form_data(@data, @encoding) unless @data.nil?
        end

        _client
      rescue Pincers::Http::RequestError => exc
        exc
      end

      BrowsingState.new response.uri, ::Nokogiri::HTML(response.content)
    end
  end
end