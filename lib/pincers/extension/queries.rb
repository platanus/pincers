module Pincers::Extension
  module Queries

    def value
      self[:value]
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
      first!.css('option[selected]', _options)
    end

    def checked(_options={})
      first!.css('input[checked]', _options)
    end

  end
end