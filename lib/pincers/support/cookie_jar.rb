require 'ostruct'

module Pincers::Support
  class CookieJar
    include Enumerable

    def initialize(_backend)
      @backend = _backend
    end

    def each
      @backend.fetch_cookies.each { |c| yield OpenStruct.new c }
    end

  end
end