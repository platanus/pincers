require 'pincers/css/xpath_visitor'

module Pincers::CSS

  class Parser

    IS_EXTENDED_RGX = /:(contains|has|first|last|even|odd|eq|gt|lt|button|checkbox|file|image|password|radio|reset|submit|text|selected|checked)([^\w\-]|$)/

    attr_reader :selector

    def is_extended?
      IS_EXTENDED_RGX === selector
    end

    def initialize(_selector)
      @selector = _selector
    end

    def to_xpath(_prefix='//')
      # use nokogiri parser and our custom visitor
      ::Nokogiri::CSS.xpath_for @selector, {
        prefix: _prefix,
        visitor: XPathVisitor.new
      }
    end

  end

end