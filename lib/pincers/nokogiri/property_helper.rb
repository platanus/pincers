module Pincers::Nokogiri

  class PropertyHelper

    # This is a small bool properties subset, I believe its enough for scrapping.
    # For information of where to find the full list: http://stackoverflow.com/questions/706384/boolean-html-attributes

    BOOL_PROPERTIES = {
      checked: [:input_checkbox, :input_radio],
      selected: [:option],
      disabled: :all, # no restrictions
      readonly: [:input_text, :input_password, :textarea],
      multiple: [:select]
    }

    attr_reader :element

    def initialize(_element)
      @element = _element
    end

    def classify
      @classify ||= begin
        name = element.name
        name = "input_#{(element[:type] || 'text')}" if name == 'input'
        name = "button_#{(element[:type] || 'submit')}" if name == 'button'
        name.to_sym
      end
    end

    def toggle(_name)
      set(_name, !get(_name))
    end

    def get(_name)
      _name = _name.to_sym

      if _name == :value
        case classify
        when :input_checkbox, :input_radio
          extract_checkable_value element
        when :select
          extract_select_value element
        when :option
          extract_option_value element
        when :textarea
          element.content
        else
          element[:value]
        end
      elsif is_boolean? _name
        !element[_name].nil?
      else
        element[_name]
      end
    end

    def set(_name, _value)
      _name = _name.to_sym

      if _name == :value
        case classify
        when :select
          set_select_value element, _value
        when :textarea
          element.content = _value
        else
          element.set_attribute(_name, _value)
        end
      elsif is_boolean? _name
        set_boolean element, _name, _value
      else
        _element.set_attribute(_name, _value)
      end
    end

    alias :[] :get
    alias :[]= :set

  private

    def is_boolean?(_name)
      permitted = BOOL_PROPERTIES[_name]
      return false if permitted.nil?
      return true if permitted == :all
      return permitted.include? classify
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
      set_boolean(to_select, :selected) unless to_select.nil?
    end

    def set_boolean(_element, _name, _value=true)
      if _value
        _element.set_attribute(_name, _name)
      else
        _element.remove_attribute(_name.to_s)
      end
    end

  end

end