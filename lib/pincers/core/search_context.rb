module Pincers::Core
  class SearchContext
    include Enumerable
    extend Forwardable

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

    def text
      wrap_errors do
        backend.extract_element_text element!
      end
    end

    def classes
      wrap_errors do
        class_attr = backend.extract_element_attribute element!, 'class'
        (class_attr || '').split(' ')
      end
    end

    def to_html
      wrap_errors do
        elements.map { |e| backend.extract_element_html e }.join
      end
    end

    # Input related

    def fill(_value)
      wrap_errors do
        backend.clear_input element!
        backend.fill_input element!
      end
    end

    def click
      wrap_errors do
        backend.click_on_element element!
      end
    end

    def select(_value)
      # TODO.
    end

    # context related

    def enter
      wrap_errors do
        RootContext.new backend.load_frame_element(element!), root.config
      end
    end

    # Any methods missing are forwarded to the main element (first)

    def method_missing(_method, *_args, &_block)
      wrap_errors do
        m = /^(.*)_all$/.match _method.to_s
        if m then
          return [] if empty?
          elements.map { |e| e.send(m[1], *_args, &_block) }
        else
          element!.send(_method, *_args, &_block)
        end
      end
    end

    def respond_to?(_method, _include_all=false)
      return true if super
      m = /^.*_all$/.match _method.to_s
      if m then
        return true if empty?
        elements.first.respond_to? m[1], _include_all
      else
        return true if empty?
        elements.first.respond_to? _method, _include_all
      end
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
