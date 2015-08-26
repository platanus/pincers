module Pincers
  module Factory

    def for_webdriver(_driver=nil, _options={}, &_block)
      require 'pincers/factories/webdriver'

      if _driver.is_a? Hash
        _options = _driver
        _driver = nil
      end

      _options[:driver] = _driver || config.webdriver_bridge

      context = Factories::Webdriver.new_context _options

      if _block
        begin
          yield context
        ensure
          context.close
        end
      else context end
    end

    def for_nokogiri(_document, _options={})
      require 'pincers/factories/nokogiri'

      _options[:document] = _document

      Factories::Nokogiri.new_context _options
    end

  end
end