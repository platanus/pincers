module Pincers::Http
  class Cookie

    attr_reader :name, :value, :domain, :path, :expires, :secure

    def initialize(_name, _value, _domain, _path=nil, _expires=nil, _secure=nil)
      @name = _name
      @value = _value
      @domain = _domain.gsub(/^\./,'').downcase # RFC 6265 5.2.3
      @path = valid_path?(_path) ? _path.downcase : '/'
      @expires = _expires
      @secure = _secure
    end

  private

    def valid_path?(_path)
      !_path.nil? && !_path.empty? && _path[0] == '/'
    end

  end


end