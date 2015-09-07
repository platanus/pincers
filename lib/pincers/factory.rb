module Pincers
  module Factory

    def for_webdriver(_driver=nil, _options={}, &_block)
      require 'pincers/webdriver/factory'

      if _driver.is_a? Hash
        _options = _driver
        _driver = nil
      end

      _options[:driver] = _driver || config.webdriver_bridge

      context = Webdriver::Factory.new_context _options

      if _block
        begin
          yield context
        ensure
          context.close
        end
      else context end
    end

    def for_nokogiri(_document, _options={})
      require 'pincers/nokogiri/factory'

      _options[:document] = _document

      Nokogiri::Factory.new_context _options
    end

  end
end