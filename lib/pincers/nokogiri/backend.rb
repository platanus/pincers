require 'pincers/core/base_backend'

module Pincers::Nokogiri
  class Backend < Pincers::Core::BaseBackend

    BOOL_PROPERTIES = [:selected, :disabled, :checked, :required]

    attr_reader :document

    def initialize(_document)
      @document = _document
    end

    def document_root
      [document]
    end

    def document_title
      document.title
    end

    def close_document
      # no closing needed
    end

    def search_by_css(_element, _selector, _limit)
      # nokogiri does not do any query level optimization when searching just one node
      _element.css _selector
    end

    def search_by_xpath(_element, _selector, _limit)
      # nokogiri does not do any query level optimization when searching just one node
      _element.xpath _selector
    end

    def extract_element_tag(_element)
      _element.name
    end

    def extract_element_text(_element)
      _element.content
    end

    def extract_element_html(_element)
      _element.to_html
    end

    def extract_element_attribute(_element, _name)
      _name = _name.to_sym
      value = _element[_name]

      if BOOL_PROPERTIES.include? _name
        value = !value.nil?
      elsif _name == :value
        value = checkbox_value_fix _element, value
      end

      value
    end

  private

    def checkbox_value_fix(_element, _value)
      if _value.nil? and _element.name.downcase == 'input' and ['checkbox', 'radio'].include? _element[:type].downcase
        'on'
      else _value end
    end

  end

end