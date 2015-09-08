require "pincers/nokogiri/backend"
require "pincers/support/http_navigator"
require "pincers/chenso/html_doc_request"
require "pincers/chenso/html_doc_cache"

module Pincers::Chenso
  class Backend < Pincers::Nokogiri::Backend

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
      set_document history.push prepare_page_request _url
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
      if BOOL_PROPERTIES.include? _name.to_sym
        if _value
          _element.set_attribute(_name, _name)
        else
          _element.remove_attribute(_name)
        end
      else
        _element.set_attribute(_name, _value)
      end
    end

    def set_element_text(_element, _value)
      case classify(_element)
      when :input_text, :input_email, :input_number, :textarea
        # TODO: validations?
        set_element_value _element, _value
      end
    end

    def click_on_element(_element, _modifiers)
      case classify(_element)
      when :a
        navigate_link _element[:href]
      when :option
        select_option _element
      when :input_checkbox
        toggle_checkbox _element
      when :input_radio
        set_radio_button _element
      when :input_submit, :button_submit
        submit_parent_form _element
      end
    end

    def as_http_client
      @client.copy
    end

  private

    def prepare_page_request(_url)
      HtmlDocRequest.new _url, {
        headers: {
          'Accept' => 'text/html,application/xhtml+xml,application/xml',
          'Cache-Control' => 'no-cache'
        }
      }
    end

    def set_element_value(_element, _value)
      _element[:value] = _value
    end

    def navigate_link(_url)
      navigate_to URI.join(document_url, _url) unless _url.nil?
    end

    def select_option(_element)
      select_element = _element.at_xpath('ancestor::select')

      if select_element[:multiple].nil?
        select_element.xpath('.//option[@selected]').each { |o| o.remove_attribute 'selected' }
        _element[:selected] = 'selected'
      elsif _element[:selected]
        _element.remove_attribute 'selected'
      else
        _element[:selected] = 'selected'
      end
    end

    def toggle_checkbox(_element)
      if _element[:checked].nil?
        _element[:checked] = 'checked'
      else
        _element.remove_attribute 'checked'
      end
    end

    def set_radio_button(_element)
      form = _element.at_xpath('ancestor::form')
      if form
        siblings = form.xpath(".//input[@type='radio' and @name='#{_element[:name]}']")
        siblings.each { |r| r.remove_attribute 'checked' }
      end
      _element[:checked] = 'checked'
    end

    def submit_parent_form(_element)
      form_element = _element.at_xpath('ancestor::form')
      submit_form form_element unless form_element.nil?
    end

    def submit_form(_form)
      # big todo!
    end

  end

end