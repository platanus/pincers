require 'pincers/http/cookie'
require 'pincers/http/utils'

module Pincers::Http
  class CookieJar

    BAD_VALUE_CHARS = /([\x00-\x20\x7F",;\\])/ # RFC 6265 - 4.1.1

    attr_reader :cookies

    def initialize(_cookies=nil)
      @cookies = _cookies || []
    end

    def copy
      self.class.new @cookies.clone
    end

    def get(_url, _name)
      for_origin(Utils.parse_uri(_url)).find { |c| c.name == _name }
    end

    def set(_cookie)
      if _cookie.name.nil? or _cookie.value.nil? or _cookie.domain.nil? or _cookie.path.nil?
        raise ArgumentError, 'Invalid cookie'
      end

      @cookies.each_with_index do |cookie, i|
        if equivalent(cookie, _cookie)
          @cookies[i] = _cookie
          return _cookie
        end
      end

      @cookies << _cookie
      _cookie
    end

    def set_raw(_request_uri, _raw)
      cookie = decode_cookie _request_uri, _raw
      set cookie unless cookie.nil?
      cookie
    end

    def set_from_header(_uri, _header)
      _header.split(/, (?=\w+=)/).map do |raw_cookie|
        set_raw _uri, raw_cookie.strip
      end
    end

    def for_origin(_uri)
      # RFC 6265 5.4.1
      @cookies.select do |c|
        # TODO: add scheme and host only checks
        domains_match c.domain, _uri.host and paths_match c.path, _uri.path
      end
    end

    def for_origin_as_header(_uri)
      for_origin(_uri).map { |c| "#{c.name}=#{quote(c.value)}" }.join('; ')
    end

  private

    def decode_cookie(_request, _raw)
      # taken from WEBrick implementation
      cookie_elem = _raw.split(/;/)
      first_elem = cookie_elem.shift
      first_elem.strip!

      name, value = first_elem.split(/\=/, 2)
      domain = nil
      path = nil
      expires = nil
      secure = nil
      # TODO: host_only = true

      cookie_elem.each do |pair|
        pair.strip!
        opt_key, opt_value = pair.split(/\=/, 2)
        opt_value = dequote(opt_value.strip) if opt_value

        case opt_key.downcase
        when "domain"
          domain = opt_value.downcase
          # TODO: host_only = false
          return nil unless domains_match(domain, _request.host) # RFC 6265 5.3.6
        when "path"
          path = opt_value.downcase if opt_value[0] == '/' # RFC 6265 5.2.4
        when "expires" then expires = opt_value
        # when "max-age" then max_age = Integer(value)
        # when "comment" then comment = value
        # when "version" then version = Integer(value)
        when "secure"  then secure = true
        end
      end

      Cookie.new(
        name,
        dequote(value),
        domain || _request.host,
        path || default_path(_request.path),
        expires,
        secure
      )
    end

    def domains_match(_cookie_domain, _request_domain)
      # RFC 6265 - 5.1.3
      # TODO: ensure request domain is not an IP
      return true if _cookie_domain == _request_domain
      if _request_domain.end_with? "#{_cookie_domain}"
        return true if _cookie_domain[0] == '.' or _request_domain.end_with? ".#{_cookie_domain}"
      end
      return false
    end

    def paths_match(_cookie_path, _request_path)
      # RFC 6265 - 5.1.4
      _request_path = '/' if _request_path.empty?
      return true if _cookie_path == _request_path
      if _request_path.start_with? _cookie_path
        return true if _cookie_path[-1] == '/' or _request_path.start_with? "#{_cookie_path}/"
      end
      return false
    end

    def default_path(_request_path)
      # RFC 6265 - 5.1.4
      return '/' unless _request_path[0] === '/'
      ls_idx = _request_path.rindex('/')
      return '/' unless ls_idx > 0
      _request_path[0..ls_idx]
    end

    def dequote(_str)
      # taken from WEBrick implementation
      ret = (/\A"(.*)"\Z/ =~ _str) ? $1 : _str.dup
      ret.gsub!(/\\(.)/, "\\1")
      ret
    end

    def quote(_str)
      # taken from WEBrick implementation and the http-cookie gem
      return _str unless BAD_VALUE_CHARS === _str
      '"' << _str.gsub(/[\\\"]/o, "\\\1") << '"'
    end

    def equivalent(_cookie_a, _cookie_b)
      return false unless _cookie_a.domain == _cookie_b.domain
      return false unless _cookie_a.path == _cookie_b.path
      return false unless _cookie_a.name == _cookie_b.name
      return true
    end

  end
end