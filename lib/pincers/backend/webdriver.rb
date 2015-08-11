require 'pincers/backend/base'

module Pincers::Backend

  class Webdriver < Base

    attr_reader :driver

    def initialize(_driver)
      super _driver
      @driver = _driver
    end

    def document_root
      [@driver]
    end

    def document_url
      @driver.current_url
    end

    def document_title
      @driver.title
    end

    def document_source
      @driver.page_source
    end

    def fetch_cookies
      @driver.manage.all_cookies
    end

    def navigate_to(_url)
      @driver.get _url
    end

    def navigate_forward(_steps)
      _steps.times { @driver.navigate.forward }
    end

    def navigate_back(_steps)
      _steps.times { @driver.navigate.back }
    end

    def refresh_document
      @driver.navigate.refresh
    end

    def search_by_css(_element, _selector)
      _element.find_elements css: _selector
    end

    def search_by_xpath(_element, _selector)
      _element.find_elements xpath: _selector
    end

    def extract_element_text(_element)

      _element.text
    end

    def extract_element_html(_element)
      if _element == @driver then @driver.page_source else _element.attribute('outerHTML') end
    end

    def extract_element_attribute(_element, _name)
      _element[_name]
    end

    def clear_input(_element)
      _element.clear
    end

    def fill_input(_element, _value)
      _element.send_keys _value
    end

    def load_frame_element(_element)
      driver.switch_to.frame _element
      self
    end

    # wait contitions

    def check_present(_elements)
      _elements.length > 0
    end

    def check_not_present(_elements)
      _elements.length == 0
    end

    def check_visible(_elements)
      check_present(_elements) and _elements.first.displayed?
    end

    def check_enabled(_elements)
      check_visible(_elements) and _elements.first.enabled?
    end

    def check_not_visible(_elements)
      not _elements.any? { |e| e.displayed? }
    end

  end

end