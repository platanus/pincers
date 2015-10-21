require 'pincers/core/base_backend'

module Pincers::Nokogiri
  class Backend < Pincers::Core::BaseBackend

    # This is a small bool properties subset, I believe its enough for scrapping.
    # For information of where to find the full list: http://stackoverflow.com/questions/706384/boolean-html-attributes

    BOOL_PROPERTIES = {
      checked: [:input_checkbox, :input_radio],
      selected: [:option],
      disabled: :all, # no restrictions
      readonly: [:input_text, :input_password, :textarea],
      multiple: [:select]
    }

    def initialize(_document)
      @document = _document
    end

    def document
      @document
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
        when :option
          extract_option_value _element
        when :textarea
          _element.content
        else
          _element[:value]
        end
      elsif is_boolean? _element, _name
        !_element[_name].nil?
      else
        _element[_name]
      end
    end

    def set_element_attribute(_element, _name, _value)
      _name = _name.to_sym

      if _name == :value
        case classify _element
        when :select
          set_select_value _element, _value
        when :textarea
          _element.content = _value
        else
          _element.set_attribute(_name, _value)
        end
      elsif is_boolean? _element, _name
        set_boolean _element, _name, _value
      else
        _element.set_attribute(_name, _value)
      end
    end

  private

    def classify(_element)
      name = _element.name
      name = "input_#{(_element[:type] || 'text')}" if name == 'input'
      name = "button_#{(_element[:type] || 'submit')}" if name == 'button'
      name.to_sym
    end

    def is_boolean?(_element, _name)
      permitted = BOOL_PROPERTIES[_name]
      return false if permitted.nil?
      return true if permitted == :all
      return permitted.include? classify(_element)
    end

    def extract_checkable_value(_element)
      value = _element[:value]
      value || 'on'
    end

    def extract_select_value(_element)
      multiple = !_element[:multiple].nil?
      selected = _element.css('option[selected]')
      if multiple
        selected.map { |o| extract_option_value(o) }
      else
        extract_option_value(selected.first)
      end
    end

    def extract_option_value(_element)
      return nil if _element.nil?
      _element[:value] || _element.content
    end

    def set_select_value(_element, _value)
      _element.xpath(".//option[@selected]").each { |o| set_boolean(o, :selected, false) }
      to_select = _element.at_xpath(".//option[@value='#{_value}']")
      to_select = _element.at_xpath(".//option[text()='#{_value}']") if to_select.nil?
      set_boolean(to_select, :selected, true) unless to_select.nil?
    end

    def set_boolean(_element, _name, _value)
      if _value
        _element.set_attribute(_name, _name)
      else
        _element.remove_attribute(_name.to_s)
      end
    end
  end
end
