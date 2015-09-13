module Pincers::Extension
  module Actions

    def set(_value=true, _options={})

      if _value.is_a? Hash
        _options = _value
        _value = true
      end

      case input_mode
      when :text
        wait :enabled
        set_text _value.to_s
      when :select
        wait :enabled
        return set_selected _value, _options
      when :checkbox, :radio
        wait :enabled
        return set_checked _value
      when :button
        wait :enabled
        click if _value
      else
        return false
      end
      true
    end

  private

    def set_selected(_value, _options)
      click
      option = if _options.key? :by_value then
        find_option_by_value _options.delete(:by_value), _options
      else
        find_option_by_label _value, _options
      end

      return false if option.nil? or option.selected?
      option.click
      true
    end

    def set_checked(_value)
      return false if _value == checked?
      click
      true
    end

    def find_option_by_label(_label, _options)
      search(_options.merge(xpath: ".//option[contains(.,'#{_label}')]")).first
    end

    def find_option_by_value(_value, _options)
      search(_options.merge(xpath: ".//option[@value='#{_value}']")).first
    end

  end
end