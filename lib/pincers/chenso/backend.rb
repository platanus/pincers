require 'pincers/nokogiri/backend'
require 'pincers/chenso/browsing_manager'
require 'pincers/chenso/html_page_request'
require 'pincers/chenso/html_form_request'
require 'pincers/chenso/html_page_cache'
require 'pincers/core/helpers/form'

module Pincers::Chenso
  class Backend < Pincers::Nokogiri::Backend

    attr_reader :client, :browser

    def initialize(_http_client)
      super nil
      @client = _http_client
      @browser = BrowsingManager.new @client
    end

    def document
      browser.document
    end

    def document_url
      browser.current_url
    end

    def navigate_to(_url)
      browser.push new_page_request _url
    end

    def navigate_forward(_steps)
      browser.forward _steps
    end

    def navigate_back(_steps)
      browser.back _steps
    end

    def refresh_document
      browser.refresh
    end

    def set_element_text(_element, _value)
      case classify _element
      when :input_text, :input_email, :input_number, :textarea
        # TODO: validations?
        set_att _element, :value, _value
      end
    end

    def click_on_element(_element, _modifiers)
      case classify _element
      when :a
        navigate_link _element
      when :option
        select_option _element
      when :input_checkbox
        toggle_checkbox _element
      when :input_radio
        set_radio_button _element
      when :input_submit, :button_submit, :button
        submit_parent_form _element
      end
    end

    def submit_form(_element)
      form = new_form _element
      load_in_target form_as_request(form), form.target
    end

    def as_http_client
      @client.fork(true)
    end

    def merge_http_client(_client)
      @client.join _client
      if _client.content and /text\/html/ === _client.content_type
        @browser.push HtmlPageCache.new(_client.uri, _client.content)
      end
    end

    def switch_to_frame(_element)
      if _element[:src] && !browser.switch_frame(_element[:src])
        browser.load_frame(_element[:src], new_page_request(_element[:src]))
      end
    end

    def switch_to_top_frame
      browser.switch_top_frame
    end

  private

    alias :get_att :extract_element_attribute
    alias :set_att :set_element_attribute

    def toggle_att(_element, _name)
      set_att(_element, _name, !get_att(_element, _name))
    end

    def navigate_link(_element)
      if get_att(_element, :href)
        load_in_target new_page_request(get_att(_element, :href)), get_att(_element, :target)
      end
    end

    def select_option(_element)
      select_element = _element.at_xpath('ancestor::select')
      unless get_att(select_element, :multiple)
        select_element.xpath('.//option[@selected]').each { |o| set_att(o, :selected, false) }
        set_att _element, :selected, true
      else
        toggle_att _element, :selected
      end
    end

    def toggle_checkbox(_element)
      toggle_att _element, :checked
    end

    def set_radio_button(_element)
      form = _element.at_xpath('ancestor::form')
      if form
        siblings = form.xpath(".//input[@type='radio' and @name='#{get_att(_element, :name)}']")
        siblings.each { |r| set_att(r, :checked, false) }
      end
      set_att _element, :checked, true
    end

    def submit_parent_form(_element)
      form_element = _element.at_xpath('ancestor::form')
      if form_element
        form = new_form form_element, _element
        load_in_target form_as_request(form), form.target
      end
    end

    def load_in_target(_request, _target)
      case _target
      when nil, '_self'
        browser.push _request
      when '_top'
        browser.switch_top_frame
        browser.push _request
      when '_parent'
        browser.switch_parent_frame
        browser.push _request
      when '_blank'
        # Should be: browser.load_window _request
        browser.switch_top_frame
        browser.push _request
      else
        frame = document.at_xpath("//iframe[@name='#{_target}']")
        switch_to_frame frame
      end
    end

    def new_page_request(_url)
      HtmlPageRequest.new _url
    end

    def form_as_request(_form)
      HtmlFormRequest.new _form
    end

    def new_form(_element, _trigger=nil)
      Pincers::Core::Helpers::Form.new self, _element, _trigger
    end
  end
end