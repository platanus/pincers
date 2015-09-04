require 'ostruct'

module Pincers::Core
  class Cookies
    include Enumerable

    def initialize(_backend)
      @backend = _backend
    end

    def each
      @backend.fetch_cookies.each { |c| yield OpenStruct.new c }
    end

  end
end