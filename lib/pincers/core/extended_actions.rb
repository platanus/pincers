module Pincers::Core
  module ExtendedActions

    def selected(_options={})
      options =  first!.css('option[selected]', _options)
      return nil if options.empty?
      options['value']
    end

  end
end