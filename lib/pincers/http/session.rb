require 'pincers/http/errors'
require 'pincers/http/cookie_jar'
require 'pincers/http/response'

module Pincers::Http
  class Session

    DEFAULT_HEADERS = {
      'Accept' => '*/*',
      'Cache-Control' => 'no-cache'
    }

    attr_reader :cookie_jar, :headers
    attr_accessor :proxy_addr, :proxy_port, :proxy_user, :proxy_password, :redirect_limit,
      :ssl_cert, :ssl_key

    def initialize(_other = nil)
      if _other
        @headers = _other.headers.clone
        @cookie_jar = _other.cookie_jar.copy
        @proxy_addr = _other.proxy_addr
        @proxy_port = _other.proxy_port
        @redirect_limit = _other.redirect_limit
        @ssl_cert = _other.ssl_cert
        @ssl_key = _other.ssl_key
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

    def proxy_auth=(_value)
      if _value
        @proxy_user, @proxy_password = _value.split ':'
      else
        @proxy_user, @proxy_password = [nil, nil]
      end
    end

    def clone
      self.class.new self
    end

    def sync(_other)
      @headers.merge! _other.headers
      _other.cookie_jar.cookies.each { |c| cookie_jar.set c }
    end

    def perform(_request)
      perform_recursive _request, @redirect_limit
    end

  private

    def perform_recursive(_request, _limit)
      raise MaximumRedirectsError.new if _limit == 0

      uri = _request.uri
      path = uri.request_uri.empty? ? '/' : uri.request_uri

      http_request = _request.native_type.new path
      http_request.body = _request.data

      copy_headers http_request, @headers
      copy_headers http_request, _request.headers
      set_cookies http_request, uri

      http_response = connect(uri).request(http_request)
      update_cookies(uri, http_response)

      case http_response
      when Net::HTTPSuccess
        Response.new(uri, http_response)
      when Net::HTTPRedirection
        location = Utils.parse_uri(http_response['location'])
        location = URI.join(uri, location) if location.relative?
        new_request = _request.clone_for_redirect(location, repeating_redirect?(http_response))
        perform_recursive(new_request, _limit - 1)
      else
        handle_error_response Response.new(uri, http_response)
      end
    end

    def repeating_redirect?(_req)
      ["307", "308"].include?(_req.code)
    end

    def connect(_uri)
      conn = Net::HTTP.new(
        _uri.host,
        _uri.port || 80,
        proxy_addr,
        proxy_port,
        proxy_user,
        proxy_password
      )

      conn.use_ssl = true if _uri.scheme == 'https'

      if ssl_cert
        conn.cert = ssl_cert
        conn.key = ssl_key
      end

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
