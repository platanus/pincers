module Pincers::Extension
  module Queries

    TEXT_INPUTS = ['text', 'email', 'number', 'email', 'color', 'password', 'search', 'tel', 'url']

    def value
      case input_mode
      when :checkbox, :radio
        if checked? then self[:value] else nil end
      else
        self[:value]
      end
    end

    def selected?
      not self[:selected].nil?
    end

    def checked?
      not self[:checked].nil?
    end

    def classes
      (self[:class] || '').split(' ')
    end

    def selected(_options={})
      first!.css('option', _options).select { |opt| opt.selected? }
    end

    def checked(_options={})
      first!.css('input', _options).select { |opt| opt.checked? }
    end

    def input_mode
      return :select if tag == 'select'
      return :button if tag == 'button' # TODO: button types
      return :text if tag == 'textarea'
      return nil if tag != 'input'

      type = (self[:type] || 'text').downcase
      return :text if TEXT_INPUTS.include? type
      type.to_sym
    end

  end
end