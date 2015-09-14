require 'pincers/core/base_backend'
require 'pincers/nokogiri/wrapper'

module Pincers::Nokogiri
  class Backend < Pincers::Core::BaseBackend

    def initialize(_document)
      @document = _document
    end

    def document
      @document
    end

    def document_root
      [document]
    end

    def document_title
      document.title
    end

    def close_document
      # no closing needed
    end

    def search_by_css(_element, _selector, _limit)
      # nokogiri does not do any query level optimization when searching just one node
      _element.css _selector
    end

    def search_by_xpath(_element, _selector, _limit)
      # nokogiri does not do any query level optimization when searching just one node
      _element.xpath _selector
    end

    def extract_element_tag(_element)
      _element.name
    end

    def extract_element_text(_element)
      _element.content
    end

    def extract_element_html(_element)
      _element.to_html
    end

    def extract_element_attribute(_element, _name)
      wrap(_element).get(_name)
    end

  private

    def wrap(_element)
      Wrapper.new _element
    end

  end

end