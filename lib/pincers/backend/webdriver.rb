require 'selenium-webdriver'
require 'pincers/backend/base'

module Pincers::Backend

  class Webdriver < Base

    attr_reader :driver

    def initialize(_driver)
      super _driver
      @driver = _driver
    end

    def javascript_enabled?
      true
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

    def search_by_css(_element, _selector, _limit)
      search _element, { css: _selector }, _limit
    end

    def search_by_xpath(_element, _selector, _limit)
      search _element, { xpath: _selector }, _limit
    end

    def extract_element_tag(_element)
      _element = ensure_element _element
      _element.tag_name
    end

    def extract_element_text(_element)
      _element = ensure_element _element
      _element.text
    end

    def extract_element_html(_element)
      return @driver.page_source if _element == @driver
      _element.attribute 'outerHTML'
    end

    def extract_element_attribute(_element, _name)
      _element = ensure_element _element
      _element[_name]
    end

    def element_is_actionable?(_element)
      # this is the base requisite in webdriver for actionable elements:
      # non displayed items will always error on action
      _element.displayed?
    end

    def set_element_text(_element, _value)
      _element = ensure_ready_for_input _element
      _element.clear
      _element.send_keys _value
    end

    def click_on_element(_element, _modifiers)
      _element = ensure_ready_for_input _element
      if _modifiers.length == 0
        _element.click
      else
        click_with_modifiers(_element, _modifiers)
      end
    end

    def right_click_on_element(_element)
      assert_has_input_devices_for :right_click_on_element
      _element = ensure_ready_for_input _element
      actions.context_click(_element).perform
    end

    def double_click_on_element(_element)
      assert_has_input_devices_for :double_click_on_element
      _element = ensure_ready_for_input _element
      actions.double_click(_element).perform
    end

    def hover_over_element(_element)
      assert_has_input_devices_for :hover_over_element
      _element = ensure_ready_for_input _element
      actions.move_to(_element).perform
    end

    def drag_and_drop(_element, _on)
      assert_has_input_devices_for :drag_and_drop
      _element = ensure_input_element _element
      actions.drag_and_drop(_element, _on).perform
    end

    def switch_to_frame(_element)
      @driver.switch_to.frame _element
    end

    def switch_to_top_frame
      @driver.switch_to.default_content
    end

    def check_visible(_elements)
      _elements.first.displayed?
    end

    def check_enabled(_elements)
      check_visible(_elements) and _elements.first.enabled?
    end

    def check_not_visible(_elements)
      not _elements.any? { |e| e.displayed? }
    end

  private

    def search(_element, _query, _limit)
      if _limit == 1
        begin
          [_element.find_element(_query)]
        rescue Selenium::WebDriver::Error::NoSuchElementError
          []
        end
      else
        _element.find_elements _query
      end
    end

    def actions
      @driver.action
    end

    def click_with_modifiers(_element, _modifiers)
      assert_has_input_devices_for :click_with_modifiers
      _modifiers.each { |m| actions.key_down m }
      actions.click _element
      _modifiers.each { |m| actions.key_up m }
      actions.perform
    end

    def assert_has_input_devices_for(_name)
      unless @driver.kind_of? Selenium::WebDriver::DriverExtensions::HasInputDevices
        raise MissingFeatureError, _name
      end
    end

    def ensure_element(_element)
      return @driver.find_element tag_name: 'html' if _element == @driver
      _element
    end

    def ensure_ready_for_input(_element)
      _element = ensure_element _element
      Selenium::WebDriver::Wait.new.until { _element.displayed? }
      _element
    end

  end

end