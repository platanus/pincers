require 'pincers/extension/queries'
require 'pincers/extension/actions'

module Pincers::Core
  class SearchContext
    include Enumerable
    extend Forwardable
    include Pincers::Extension::Queries
    include Pincers::Extension::Actions

    attr_accessor :parent, :elements

    def_delegators :elements, :length, :count, :empty?

    def initialize(_elements, _parent)
      @elements = _elements
      @parent = _parent
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

    def each
      elements.each { |el| yield wrap_elements [el] }
    end

    def [](*args)
      if args[0].is_a? String or args[0].is_a? Symbol
        wrap_errors do
          backend.extract_element_attribute element!, args[0]
        end
      else
        wrap_elements Array(elements.send(:[],*args))
      end
    end

    def first
      if elements.first.nil? then nil else wrap_elements [elements.first] end
    end

    def first!
      first or raise Pincers::EmptySetError.new(self)
    end

    def last
      if elements.last.nil? then nil else wrap_elements [elements.last] end
    end

    def css(_selector, _options={})
      search_with_options _options do
        explode_elements { |e| backend.search_by_css e, _selector }
      end
    end

    def xpath(_selector, _options={})
      search_with_options _options do
        explode_elements { |e| backend.search_by_xpath e, _selector }
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

    def wrap_elements(_elements)
      SearchContext.new _elements, self
    end

    def search_with_options(_options, &_block)
      wrap_errors do
        wait_for = _options.delete(:wait)
        return wrap_elements _block.call unless wait_for
        wrap_elements poll_until(wait_for, _options, &_block)
      end
    end

    def explode_elements
      elements.inject([]) do |r, element|
        r + yield(element)
      end
    end

    def poll_until(_condition, _options, &_search)
      check_method = "check_#{_condition}"
      raise Pincers::MissingFeatureError.new check_method unless backend.respond_to? check_method

      timeout = _options.fetch :timeout, root.default_timeout
      interval = _options.fetch :interval, root.default_interval
      end_time = Time.now + timeout

      until Time.now > end_time
        new_elements = _search.call
        return new_elements if backend.send check_method, new_elements
        sleep interval
      end

      raise Pincers::ConditionTimeoutError.new self, _condition
    end

  end
end
