require 'pincers/http/utils'

module Pincers::Core::Helpers

  class Form

    attr_reader :backend

    def initialize(_backend, _form_element, _trigger_element = nil)
      @backend = _backend
      @form = _form_element
      @trigger = _trigger_element
      @force_multipart = false
    end

    def action
      @action ||= begin
        (trigger_attr(:formaction) || form_attr(:action) || '')
      end
    end

    def method
      @method ||= begin
        (trigger_attr(:formmethod) || form_attr(:method) || 'get').downcase.to_sym
      end
    end

    def target
      @target ||= begin
        trigger_attr(:formtarget) || form_attr(:target)
      end
    end

    def encoding
      process_inputs
      @encoding ||= begin
        if @force_multipart
          Pincers::Http::Utils::FORM_MULTIPART
        else
          trigger_attr(:formenctype) || form_attr(:enctype) || Pincers::Http::Utils::FORM_URLENCODED
        end
      end
    end

    def inputs
      process_inputs
      @inputs
    end

  private

    def trigger_attr(_name)
      return nil if @trigger.nil?
      backend.extract_element_attribute(@trigger, _name)
    end

    def form_attr(_name)
      backend.extract_element_attribute(@form, _name)
    end

    def process_inputs
      return unless @inputs.nil?
      elements = backend.search_by_xpath(@form, './/*[@name]', nil)
      @inputs = elements.map do |input|
        category = categorize_input input
        next nil if category.nil?

        @force_multipart = true if category == :multipart

        value = backend.extract_element_attribute(input, :value)
        next nil if value.nil?

        name = backend.extract_element_attribute(input, :name)
        [name, value]
      end.reject(&:nil?)
    end

    def categorize_input(_input)
      case backend.extract_element_tag _input
      when 'input'
        input_type = backend.extract_element_attribute(_input, :type)
        return nil if input_type == 'submit' && !is_trigger?(_input)
        return nil if input_type == 'checkbox' && !is_checked?(_input)
        return nil if input_type == 'radio' && !is_checked?(_input)
        input_type == 'file' ? :multipart : :urlencoded
      when 'button'
        input_type = backend.extract_element_attribute(_input, :type) || 'submit'
        return nil if input_type != 'submit' || !is_trigger?(_input)
        :urlencoded
      when 'textarea', 'select'
        :urlencoded
      else
        nil
      end
    end

    def is_trigger?(_input)
      return false if @trigger.nil?
      backend.elements_equal _input, @trigger
    end

    def is_checked?(_input)
      backend.extract_element_attribute _input, :checked
    end
  end
end