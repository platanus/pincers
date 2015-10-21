module Pincers::Chenso
  class HtmlPageRequest

    DEFAULT_HEADERS = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml',
      'Cache-Control' => 'no-cache'
    }

    def initialize(_url, _method=:get, _data=nil, _encoding=nil)
      @url = _url
      @method = _method
      @data = _data
      @encoding = _encoding
    end

    def execute(_client)
      @uri = _client.absolute_uri_for @url if @uri.nil?

      _client.send(@method, @uri) do |request|
        request.headers.merge DEFAULT_HEADERS
        request.set_form_data(@data, @encoding) unless @data.nil?
      end

      ::Nokogiri::HTML _client.content
    end
  end
end