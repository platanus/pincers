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

    def set(_parts)
      return nil unless _parts[:domain]
      return nil unless _parts[:name]
      return nil unless _parts[:value]

      cookie = Cookie.new(
        _parts[:name],
        _parts[:value],
        _parts[:domain].gsub(/^\./,''),
        _parts[:path] || '/',
        _parts[:expires],
        _parts[:secure]
      )

      replace_cookie cookie
      cookie
    end

    def set_raw(_uri, _raw)
      cookie = decode_cookie _raw

      cookie.domain = compute_domain cookie.domain, _uri.host
      cookie.path = compute_path cookie.path, _uri.path

      return nil if cookie.domain.nil? or cookie.path.nil?

      replace_cookie(cookie)
      cookie
    end

    def for_origin(_uri)
      @cookies.select do |c|
        domains_match c.domain, _uri.host and paths_match c.path, _uri.path
      end
    end

    def for_origin_as_header(_uri)
      for_origin(_uri).map { |c| "#{c.name}=#{quote(c.value)}" }.join('; ')
    end

  private

    def decode_cookie(_raw)
      # taken from WEBrick implementation
      cookie_elem = _raw.split(/;/)
      first_elem = cookie_elem.shift
      first_elem.strip!
      key, value = first_elem.split(/\=/, 2)

      cookie = Cookie.new(key, dequote(value))
      cookie_elem.each do |pair|
        pair.strip!
        key, value = pair.split(/\=/, 2)
        value = dequote(value.strip) if value

        case key.downcase
        when "domain"  then cookie.domain  = value.downcase
        when "path"    then cookie.path    = value.downcase
        when "expires" then cookie.expires = value
        # when "max-age" then cookie.max_age = Integer(value)
        # when "comment" then cookie.comment = value
        # when "version" then cookie.version = Integer(value)
        when "secure"  then cookie.secure = true
        end
      end

      cookie
    end

    def domains_match(_cookie_domain, _request_domain)
      # RFC 6265 - 5.1.3
      # TODO: ensure request domain is not an IP
      return true if _cookie_domain == _request_domain
      return true if _request_domain.end_with? ".#{_cookie_domain}"
      return false
    end

    def paths_match(_cookie_path, _request_path)
      # RFC 6265 - 5.1.4
      _request_path = '/' if _request_path.empty?
      return true if _cookie_path == _request_path
      return true if _cookie_path[-1] == '/' and _request_path.start_with? _cookie_path
      return true if _request_path.start_with? "#{_cookie_path}/"
      return false
    end

    def compute_domain(_cookie_domain, _request_domain)
      return _request_domain if _cookie_domain.nil?
      # cookies with different domain are discarded
      return nil unless _cookie_domain.end_with? _request_domain
      return _cookie_domain.gsub(/^\./,'') # remove leading dot
    end

    def compute_path(_cookie_path, _request_path)
      default_path = compute_default_path(_request_path)
      return default_path if _cookie_path.nil?
      return nil unless _cookie_path.start_with? default_path
      return _cookie_path
    end

    def compute_default_path(_request_path)
      # RFC 6265 - 5.1.4
      return '/' unless _request_path[0] === '/'
      ls_idx = _request_path.rindex('/')
      return '/' unless ls_idx > 0
      _request_path[0..ls_idx]
    end

    def replace_cookie(_cookie)
      @cookies.each_with_index do |cookie, i|
        if equivalent(cookie, _cookie)
          @cookies[i] = _cookie
          return
        end
      end

      @cookies << _cookie
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