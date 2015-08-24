module Pincers::Backend

  class Base

    attr_reader :document

    def initialize(_document)
      @document = _document
    end

    def javascript_enabled?
      false
    end

    def document_root
      ensure_implementation :document_root
    end

    def document_url
      ensure_implementation :document_url
    end

    def document_title
      ensure_implementation :document_title
    end

    def fetch_cookies
      ensure_implementation :fetch_cookies
    end

    def navigate_to(_url)
      ensure_implementation :navigate_to
    end

    def navigate_forward(_steps)
      ensure_implementation :navigate_forward
    end

    def navigate_back(_steps)
      ensure_implementation :navigate_back
    end

    def refresh_document
      ensure_implementation :refresh_document
    end

    def search_by_css(_element, _selector, _limit)
      ensure_implementation :search_by_css
    end

    def search_by_xpath(_element, _selector, _limit)
      ensure_implementation :search_by_xpath
    end

    def extract_element_tag(_element)
      ensure_implementation :extract_element_tag
    end

    def extract_element_text(_element)
      ensure_implementation :extract_element_text
    end

    def extract_element_html(_element)
      ensure_implementation :extract_element_html
    end

    def extract_element_attribute(_element, _name)
      ensure_implementation :extract_element_attribute
    end

    def clear_input(_element)
      ensure_implementation :clear_input
    end

    def set_element_text(_element, _value)
      ensure_implementation :set_element_text
    end

    def click_on_element(_element, _modifiers)
      ensure_implementation :click_on_element
    end

    def right_click_on_element(_element)
      ensure_implementation :right_click_on_element
    end

    def double_click_on_element(_element)
      ensure_implementation :double_click_on_element
    end

    def hover_over_element(_element)
      ensure_implementation :hover_over_element
    end

    def drag_and_drop(_element, _into)
      ensure_implementation :drag_and_drop
    end

    def switch_to_frame(_element)
      ensure_implementation :switch_to_frame
    end

    def switch_to_top_frame
      ensure_implementation :switch_to_top_frame
    end

    def switch_to_parent_frame
      ensure_implementation :switch_to_parent_frame
    end

  private

    def ensure_implementation(_name)
      raise Pincers::MissingFeatureError.new _name
    end

  end

end