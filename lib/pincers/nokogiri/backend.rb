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

      if _name == :value
        case classify _element
        when :input_checkbox, :input_radio
          extract_checkable_value _element
        when :select
          extract_select_value _element
        else
          _element[:value]
        end
      elsif BOOL_PROPERTIES.include? _name
        !_element[_name].nil?
      else
        _element[_name]
      end
    end

  private

    def set_document(_document)
      @document = _document unless _document.nil?
    end

    def classify(_element)
      name = _element.name
      name = "input_#{(_element[:type] || 'text')}" if name == 'input'
      name = "button_#{(_element[:type] || 'submit')}" if name == 'button'
      name.to_sym
    end

    def extract_checkable_value(_element)
      value = _element[:value]
      value || 'on'
    end

    def extract_select_value(_element)
      multiple = !_element[:multiple].nil?
      selected = _element.css('option[selected]')
      if multiple
        selected.map { |o| option_value(o) }
      else
        option_value(selected.first)
      end
    end

    def option_value(_element)
      return nil if _element.nil?
      _element[:value] || _element.content
    end

  end

end