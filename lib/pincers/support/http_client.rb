require "uri"
require "pincers/support/cookie_jar"

module Pincers::Support
  class HttpClient

    class HttpRequestError < StandardError
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

    attr_reader :proxy, :proxy_addr, :proxy_port, :cookies, :default_headers

    def initialize(_options={})
      @proxy = _options[:proxy]
      @proxy_addr, @proxy_port = _options[:proxy].split ':' if @proxy

      @cookies = _options[:cookies] || CookieJar.new
      @default_headers = _options[:headers]
    end

    def copy
      self.class.new({
        proxy: @proxy,
        cookies: @cookies.copy,
        headers: @default_headers
      })
    end

    def get(_url, _query={}, _headers={})
      # TODO: append query string?
      perform_request Net::HTTP::Get, URI(_url), _headers
    end

    def post(_url, _data, _headers={})
      perform_request Net::HTTP::Post, URI(_url), _headers do |req|
        req.body = prepare_data(_data)
      end
    end

    def put(_url, _data, _headers={})
      perform_request Net::HTTP::Put, URI(_url), _headers do |req|
        req.body = prepare_data(_data)
      end
    end

    def delete(_url)
      perform_request Net::HTTP::Delete, URI(_url), _headers
    end

  private

    def perform_request(_req_type, _uri, _headers, _limit=10, &_block)

      raise MaximumRedirectsError.new if _limit == 0

      request = _req_type.new(_uri.request_uri.empty? ? '/' : _uri.request_uri)
      build_headers(request, _headers)
      set_cookies(request, _uri)
      _block.call(request) if _block

      response = build_client(_uri).request request

      case response
      when Net::HTTPSuccess then
        update_cookies(_uri, response)
        response
      when Net::HTTPRedirection then
        location = response['location']
        perform_request(_req_type, URI.parse(location), _headers, _limit - 1, &_block)
      else
        handle_error_response response
      end
    end

    def build_client(uri)
      client = Net::HTTP.new uri.host, uri.port || 80, proxy_addr, proxy_port
      client.use_ssl = true if uri.scheme == 'https'
      client.verify_mode = OpenSSL::SSL::VERIFY_NONE
      client
    end

    def handle_error_response(_response)
      raise HttpRequestError.new _response
    end

    def prepare_data(_data)
      if _data.is_a? Hash
        _data.keys.map { |k| "#{k}=#{_data[k]}" }.join '&'
      else _data end
    end

    def build_headers(_request, _headers)
      copy_headers _request, @default_headers if @default_headers
      copy_headers _request, _headers
    end

    def set_cookies(_request, _uri)
      _request['Cookie'] = @cookies.for_origin_as_header _uri
    end

    def update_cookies(_uri, _response)
      cookies = _response.get_fields('set-cookie')
      cookies.each { |raw| @cookies.set_raw _uri, raw } if cookies
    end

    def copy_headers(_request, _headers)
      _headers.keys.each { |k| _request[k] = _headers[k] }
    end
  end
end