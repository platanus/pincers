module Pincers::Support
  class Query

    attr_reader :lang, :query, :limit

    def initialize(_backend, _lang, _query, _limit)
      @backend = _backend
      @lang = _lang
      @query = _query
      @limit = _limit
    end

    def execute(_elements)
      fun = case @lang
      when :xpath then :search_by_xpath
      else :search_by_css end

      explode_elements _elements, fun
    end

    def explode_elements(_elements, _fun)
      _elements.inject([]) do |r, element|
        limit = @limit.nil? ? nil : @limit - r.count
        r = r + @backend.send(_fun, element, @query, limit)
        break r if !@limit.nil? && r.length >= @limit
        next r
      end
    end

  end
end