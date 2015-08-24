module Pincers::Support
  class Query

    attr_reader :lang, :query, :limit

    def initialize(_backend, _lang, _query, _limit)
      @backend = _backend
      @lang = _lang
      @query = _query
      @limit = _limit
    end

    def execute(_elements, _force_limit=nil)
      fun = case @lang
      when :xpath then :search_by_xpath
      else :search_by_css end

      explode_elements _elements, fun, _force_limit || @limit
    end

    def explode_elements(_elements, _fun, _limit)
      _elements.inject([]) do |r, element|
        limit = _limit.nil? ? nil : _limit - r.count
        r = r + @backend.send(_fun, element, @query, limit)
        break r if !_limit.nil? && r.length >= _limit
        next r
      end
    end

  end
end