require 'pincers/extension/queries'
require 'pincers/extension/actions'
require 'pincers/extension/labs'
require 'pincers/support/query'

module Pincers::Core
  class SearchContext
    include Enumerable
    extend Forwardable
    include Pincers::Extension::Queries
    include Pincers::Extension::Actions
    include Pincers::Extension::Labs

    attr_reader :parent, :query

    def_delegators :elements, :length, :count, :empty?

    def initialize(_elements, _parent, _query)
      @elements = _elements
      @scope = if @elements.nil? then nil else :all end
      @parent = _parent
      @query = _query
      @waiting = false
    end

    def frozen?
      !backend.javascript_enabled? || @query.nil?
    end

    def root
      parent.root
    end

    def root?
      false
    end

    def backend
      root.backend
    end

    def elements
      reload_elements :all
      @elements
    end

    def element
      reload_elements :single
      @elements.first
    end

    def element!
      wait(:present) if should_wait?
      raise Pincers::EmptySetError.new self if element.nil?
      element
    end

    def reload
      raise Pincers::FrozenSetError.new self if frozen?
      parent.reload if parent_needs_reload?
      wrap_errors { reload_elements }
      self
    end

    def each
      elements.each { |el| yield wrap_siblings [el] }
    end

    def [](*args)
      if args[0].is_a? String or args[0].is_a? Symbol
        attribute args[0]
      else
        wrap_siblings Array(elements.send(:[],*args))
      end
    end

    def []=(key, value)
      attribute key, value
    end

    def first
      wait?(:present) if should_wait?
      if element.nil? then nil else wrap_siblings [element] end
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

    def attribute(_name, _value=nil)
      wrap_errors do
        if _value.nil?
          backend.extract_element_attribute element!, _name
        else
          backend.set_element_attribute element!, _name, _value
        end
      end
    end

    def tag
      wrap_errors do
        backend.extract_element_tag(element!).downcase
      end
    end

    def text
      wrap_errors do
        elements.map { |e| backend.extract_element_text e }.join
      end
    end

    def to_html
      wrap_errors do
        elements.map { |e| backend.extract_element_html e }.join
      end
    end

    # input related

    def set_text(_value)
      perform_action { |el| backend.set_element_text el, _value }
    end

    def click(*_modifiers)
      perform_action { |el| backend.click_on_element el, _modifiers }
    end

    def right_click
      perform_action { |el| backend.right_click_on_element el }
    end

    def double_click
      perform_action { |el| backend.double_click_on_element el }
    end

    def hover
      perform_action { |el| backend.hover_over_element el }
    end

    def drag_to(_element)
      wrap_errors do
        if advanced_mode?
          wait_actionable
          _element.wait_actionable
        end

        backend.drag_and_drop element!, _element.element!
      end
      self
    end

    # context related

    def goto
      root.goto frame: self
    end

    # waiting

    def wait?(_condition=nil, _options={}, &_block)

      if _condition.is_a? Hash
        _options = _condition
        _condition = nil
      end

      poll_until(_options) do
        next ensure_block _block if _block

        case _condition
        when :present
          ensure_present
        when :actionable
          ensure_present and ensure_actionable
        when :enabled
          ensure_present and !attribute(:disabled)
        else
          ensure_present and !!attribute(_condition)
        end
      end
    end

    def wait(_condition=nil, _options={}, &_block)

      if _condition.is_a? Hash
        _options = _condition
        _condition = nil
      end

      raise Pincers::ConditionTimeoutError.new(self, _condition) unless wait?(_condition, _options, &_block)
      return self
    end

  private

    def should_wait?
      !frozen? && !advanced_mode? && !@waiting
    end

    def advanced_mode?
      root.advanced_mode?
    end

    def ensure_present
      reload if element.nil?
      not element.nil?
    end

    def ensure_actionable
      backend.element_is_actionable? element
    end

    def ensure_block(_block)
      begin
        @waiting = true
        _block.call(self) != false
      rescue Pincers::NavigationError
        return false
      ensure
        @waiting = false
      end
    end

    def wrap_errors
      begin
        yield
      rescue Pincers::Error
        raise
      rescue Exception => exc
        raise Pincers::BackendError.new(self, exc)
      end
    end

    def perform_action
      wrap_errors do
        wait(:actionable) if should_wait?
        yield elements.first
      end
      self
    end

    def wrap_siblings(_elements)
      SearchContext.new _elements, parent, nil
    end

    def wrap_childs(_query)
      child_elements = if advanced_mode? then _query.execute(elements) else nil end
      SearchContext.new child_elements, self, _query
    end

    def parent_needs_reload?
      !parent.frozen? && parent.elements.count == 0
    end

    def reload_elements(_scope=nil)
      case _scope
      when :all
        return if @scope == :all
        @scope = :all
      when :single
        return unless @scope.nil?
        @scope = :single
      end

      if @scope == :single
        @elements = @query.execute parent.elements, 1 # force single record
      else
        @elements = @query.execute parent.elements
        @scope = :all if @scope.nil?
      end
    end

    def poll_until(_options={})
      timeout = _options.fetch :timeout, root.default_timeout
      interval = _options.fetch :interval, root.default_interval
      end_time = Time.now + timeout

      while Time.now <= end_time
        return true if !!yield
        sleep interval
      end

      return false
    end

  end
end
