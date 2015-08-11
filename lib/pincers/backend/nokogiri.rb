require 'pincers/backend/base'

module Pincers::Backend

  class Nokogiri < Base

    def document_root
      [document]
    end

    def document_title
      document.title
    end

    def search_by_css(_element, _selector)
      _element.css _selector
    end

    def search_by_xpath(_element, _selector)
      _element.xpath _selector
    end

    def extract_element_text(_element)
      _element.content
    end

    def extract_element_html(_element)
      _element.to_html
    end

    def extract_element_attribute(_element, _name)
      _element[_name]
    end

  end

end