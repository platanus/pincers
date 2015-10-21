require 'pincers/css/parser'
require 'pincers/support/xpath_builder'

module Pincers::Core::Helpers
  class Query

    def self.build_from_options(_backend, _selector, _options = {}, &_block)
      limit = _options.delete(:limit)
      lang = :xpath
      exp = nil

      if _selector
        parser = Pincers::CSS::Parser.new _selector
        if parser.is_extended?
          exp = parser.to_xpath('.//') # Should we use // for root?
          exp = exp.first if exp.length == 1
        else
          lang = :css
          exp = _selector
        end
      elsif _options[:xpath]
        exp = _options[:xpath]
      else
        builder = Pincers::Support::XPathBuilder.new _options
        _block.call builder unless _block.nil?
        exp = builder.expression
      end

      self.new _backend, lang, exp, limit
    end

    attr_reader :lang, :query, :limit

    def initialize(_backend, _lang, _query, _limit)
      @backend = _backend
      @lang = _lang
      @query = _query
      @limit = _limit
    end

    def execute(_elements, _force_limit = nil)
      fun = case @lang
      when :xpath then :search_by_xpath
      else :search_by_css end

      query_elements _elements, fun, _force_limit || @limit
    end

  private

    def query_elements(_elements, _fun, _limit)
      elements = []
      explode_elements(_elements) do |element, query|
        limit = _limit.nil? ? nil : _limit - elements.count
        elements += @backend.send(_fun, element, query, limit)
        break if !_limit.nil? && elements.length >= _limit
      end
      elements
    end

    def explode_elements(_elements)
      _elements.each do |element|
        if @query.is_a? Array
          @query.each { |q| yield element, q }
        else
          yield element, @query
        end
      end
    end
  end
end