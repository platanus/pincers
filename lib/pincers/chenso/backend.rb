require "pincers/nokogiri/backend"
require "pincers/chenso/browsing_manager"
require "pincers/chenso/html_doc_request"
require "pincers/chenso/html_doc_cache"
require "pincers/chenso/form_helper"

module Pincers::Chenso
  class Backend < Pincers::Nokogiri::Backend

    DEFAULT_HEADERS = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml',
      'Cache-Control' => 'no-cache'
    }

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

    def set_element_attribute(_element, _name, _value)
      wrap(_element).set(_name, _value)
    end

    def set_element_text(_element, _value)
      element = wrap(_element)
      case element.classify
      when :input_text, :input_email, :input_number, :textarea
        # TODO: validations?
        element[:value] = _value
      end
    end

    def click_on_element(_element, _modifiers)
      element = wrap(_element)
      case element.classify
      when :a
        navigate_link element
      when :option
        select_option element
      when :input_checkbox
        toggle_checkbox element
      when :input_radio
        set_radio_button element
      when :input_submit, :button_submit, :button
        submit_parent_form element
      end
    end

    def submit_form(_element)
      _element = wrap(_element)
      form = FormHelper.new document_url, _element
      load_in_target form.submit, _element[:target]
    end

    def as_http_client
      @client.copy
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

    def new_page_request(_url)
      _url = URI.join(document_url, _url) if document_url
      prepare_page_request HtmlDocRequest.new _url
    end

    def prepare_page_request(_request)
      _request.headers.merge! DEFAULT_HEADERS
      _request
    end

    def navigate_link(_element)
      if _element[:href]
        load_in_target new_page_request(_element[:href]), _element[:target]
      end
    end

    def select_option(_element)
      select_element = _element.at_xpath('ancestor::select')

      unless select_element[:multiple]
        select_element.xpath('.//option[@selected]').each { |o| o[:selected] = false }
        _element[:selected] = true
      else
        _element.toggle(:selected)
      end
    end

    def toggle_checkbox(_element)
      _element.toggle(:checked)
    end

    def set_radio_button(_element)
      form = _element.at_xpath('ancestor::form')
      if form
        siblings = form.xpath(".//input[@type='radio' and @name='#{_element[:name]}']")
        siblings.each { |r| r[:checked] = false }
      end
      _element[:checked] = true
    end

    def submit_parent_form(_element)
      form_element = _element.at_xpath('ancestor::form')
      if form_element
        form = FormHelper.new(document_url, form_element)
        target = _element[:formtarget] || form_element[:target]
        load_in_target form.submit(_element), target
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

  end

end