require "pincers/nokogiri/backend"
require "pincers/support/http_navigator"
require "pincers/chenso/html_doc_request"
require "pincers/chenso/html_doc_cache"
require "pincers/chenso/form_helper"

module Pincers::Chenso
  class Backend < Pincers::Nokogiri::Backend

    DEFAULT_HEADERS = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml',
      'Cache-Control' => 'no-cache'
    }

    attr_reader :client, :history

    def initialize(_http_client)
      super nil
      @client = _http_client
      @history = Pincers::Support::HttpNavigator.new _http_client
    end

    def document_url
      history.current_url
    end

    def navigate_to(_url)
      push_request new_page_request _url
    end

    def navigate_forward(_steps)
      set_document history.forward _steps
    end

    def navigate_back(_steps)
      set_document history.back _steps
    end

    def refresh_document
      set_document history.refresh
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
        navigate_link element[:href]
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
      form = FormHelper.new document_url, wrap(_element)
      push_request form.submit
    end

    def as_http_client
      @client.copy
    end

  private

    def new_page_request(_url)
      prepare_page_request HtmlDocRequest.new _url
    end

    def prepare_page_request(_request)
      _request.headers.merge! DEFAULT_HEADERS
      _request
    end

    def push_request(_request)
      set_document history.push _request
    end

    def navigate_link(_url)
      navigate_to URI.join(document_url, _url) unless _url.nil?
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
        push_request form.submit _element
      end
    end

  end

end