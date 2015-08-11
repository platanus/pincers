module Pincers::Backend

  class Base

    attr_reader :document

    def initialize(_document)
      @document = _document
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

    def document_source
      ensure_implementation :document_source
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

    def search_by_css(_element, _selector)
      ensure_implementation :search_by_css
    end

    def search_by_xpath(_element, _selector)
      ensure_implementation :search_by_xpath
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

    def fill_input(_element, _value)
      ensure_implementation :fill_input
    end

    def load_frame_element(_element)
      ensure_implementation :load_frame_element
    end

  private

    def ensure_implementation(_name)
      raise MissingFeatureError.new _name
    end

  end

end