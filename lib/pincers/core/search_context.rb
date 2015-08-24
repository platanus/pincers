require 'pincers/extension/queries'
require 'pincers/extension/actions'
require 'pincers/support/query'

module Pincers::Core
  class SearchContext
    include Enumerable
    extend Forwardable
    include Pincers::Extension::Queries
    include Pincers::Extension::Actions

    attr_reader :parent, :elements, :query

    def_delegators :elements, :length, :count, :empty?

    def initialize(_elements, _parent, _query)
      @elements = _elements
      @parent = _parent
      @query = _query
    end

    def frozen?
      !backend.javascript_enabled? || @query.nil?
    end

    def root
      parent.root
    end

    def backend
      root.backend
    end

    def document
      backend.document
    end

    def element
      elements.first
    end

    def element!
      raise Pincers::EmptySetError.new self if empty?
      element
    end

    def reload(_full=false)
      raise Pincers::FrozenSetError.new self if frozen?
      parent.reload _full if parent_needs_reload? _full
      wrap_errors { reload_elements }
      self
    end

    def each
      elements.each { |el| yield wrap_siblings [el] }
    end

    def [](*args)
      if args[0].is_a? String or args[0].is_a? Symbol
        wrap_errors do
          backend.extract_element_attribute element!, args[0]
        end
      else
        wrap_siblings Array(elements.send(:[],*args))
      end
    end

    def first
      if elements.first.nil? then nil else wrap_siblings [elements.first] end
    end

    def first!
      wrap_siblings [element!]
    end

    def last
      if elements.last.nil? then nil else wrap_siblings [elements.last] end
    end

    def css(_selector, _options={})
      wrap_errors do
        query = Pincers::Support::Query.new backend, :css, _selector, _options[:limit]
        wrap_childs query
      end
    end

    def xpath(_selector, _options={})
      wrap_errors do
        query = Pincers::Support::Query.new backend, :xpath, _selector, _options[:limit]
        wrap_childs query
      end
    end

    def tag
      wrap_errors do
        backend.extract_element_tag(element!).downcase
      end
    end

    def text
      wrap_errors do
        backend.extract_element_text element!
      end
    end

    def to_html
      wrap_errors do
        elements.map { |e| backend.extract_element_html e }.join
      end
    end

    # Input related

    def set_text(_value)
      wrap_errors do
        backend.set_element_text element!, _value
      end
      self
    end

    def click(*_modifiers)
      wrap_errors do
        backend.click_on_element element!, _modifiers
      end
      self
    end

    def right_click
      wrap_errors do
        backend.right_click_on_element element!
      end
      self
    end

    def double_click
      wrap_errors do
        backend.double_click_on_element element!
      end
      self
    end

    def hover
      wrap_errors do
        backend.hover_over_element element!
      end
      self
    end

    def drag_to(_element)
      wrap_errors do
        backend.drag_and_drop element!, _element.element!
      end
      self
    end

    # context related

    def goto
      root.goto frame: self
    end

  private

    def wrap_errors
      begin
        yield
      rescue Pincers::Error
        raise
      rescue Exception => exc
        raise Pincers::BackendError.new self, exc
      end
    end

    def wrap_siblings(_elements)
      SearchContext.new _elements, parent, nil
    end

    def wrap_childs(_query)
      SearchContext.new _query.execute(elements), self, _query
    end

    def parent_needs_reload?(_full)
      (parent.elements.count == 0) || (_full && !parent.frozen?)
    end

    def reload_elements
      @elements = @query.execute parent.elements
    end

  end
end
