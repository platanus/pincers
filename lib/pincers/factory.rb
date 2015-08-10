require 'pincers/core/root_context'

module Pincers
  module Factory

    def for_webdriver(_driver, _options={})
      require 'pincers/backend/webdriver'

      unless _driver.is_a? Selenium::WebDriver::Driver
        _driver = Selenium::WebDriver::Driver.for _driver, _options
      end

      context Backend::Webdriver.new _driver
    end

    def for_nokogiri(_document, _options={})
      require 'pincers/backend/nokogiri'

      unless _document.is_a? ::Nokogiri::HTML::Document
        _document = ::Nokogiri::HTML _document, _options[:url], _options[:encoding], _options[:flags]
      end

      context Backend::Nokogiri.new _document
    end

  private

    def context(_backend)
      Core::RootContext.new _backend
    end

  end
end