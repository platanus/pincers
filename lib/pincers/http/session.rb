require 'pincers/http/errors'
require 'pincers/http/cookie_jar'

module Pincers::Http
  class Session

    DEFAULT_HEADERS = {
      'Accept' => '*/*',
      'Cache-Control' => 'no-cache'
    }

    attr_reader :cookie_jar, :headers
    attr_accessor :proxy_addr, :proxy_port, :redirect_limit

    def initialize(_other = nil)
      if _other
        @headers = _other.headers.clone
        @cookie_jar = _other.cookie_jar.copy
        @proxy_addr = _other.proxy_addr
        @proxy_port = _other.proxy_port
        @redirect_limit = _other.redirect_limit
      else
        @headers = DEFAULT_HEADERS
        @cookie_jar = CookieJar.new
        @redirect_limit = 10
      end
    end

    def proxy=(_value)
      if _value
        @proxy_addr, @proxy_port = _value.split ':'
      else
        @proxy_addr, @proxy_port = [nil, nil]
      end
    end

    def clone
      self.class.new self
    end

    def perform(_request)
      perform_recursive _request, @redirect_limit, nil
    end

  private

    def perform_recursive(_request, _limit, _redirect)
      raise MaximumRedirectsError.new if _limit == 0

      uri = _redirect || _request.uri
      path = uri.request_uri.empty? ? '/' : uri.request_uri

      http_request = _request.native_type.new path
      http_request.body = _request.data

      copy_headers http_request, @headers
      copy_headers http_request, _request.headers
      set_cookies http_request, uri

      http_response = connect(uri).request http_request

      case http_response
      when Net::HTTPSuccess then
        update_cookies(uri, http_response)
        http_response.uri = uri # uri is not always set by net/http
        http_response
      when Net::HTTPRedirection then
        location = Utils.parse_uri(http_response['location'])
        perform_recursive(_request, _limit - 1, location)
      else
        handle_error_response http_response
      end
    end

    def connect(_uri)
      conn = Net::HTTP.new _uri.host, _uri.port || 80, @proxy_addr, @proxy_port
      conn.use_ssl = true if _uri.scheme == 'https'
      conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      conn
    end

    def handle_error_response(_http_response)
      raise RequestError.new _http_response
    end

    def copy_headers(_request, _headers)
      _headers.keys.each { |k| _request[k] = _headers[k] }
    end

    def set_cookies(_request, _uri)
      _request['Cookie'] = @cookie_jar.for_origin_as_header _uri
    end

    def update_cookies(_uri, _response)
      fields = _response.get_fields('set-cookie')
      fields.each { |field| cookie_jar.set_from_header _uri, field } if fields
    end
  end
end
