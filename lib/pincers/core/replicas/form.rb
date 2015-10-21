require 'pincers/core/helpers/form'

module Pincers::Core::Replicas
  class Form

    def initialize(_backend, _element)
      @backend = _backend
      @form = Pincers::Core::Helpers::Form.new(_backend, _element)
      @pairs = @form.inputs
    end

    def set(_name, _value, _replace = true)
      _name = _name.to_s
      unset(_name) if _replace
      @pairs << [_name, _value]
      _value
    end

    def unset(_name)
      _name = _name.to_s
      @pairs.delete_if { |p| p[0] == _name }
      self
    end

    def get(_name, _as_array = false)
      _name = _name.to_s
      values = @pairs.select { |p| p[0] == _name }.map { |p| p[1] }
      _as_array = true if _na me.include? '['
      return values.first if values.length <= 1 && !_as_array
      values
    end

    alias :[] :get
    alias :[]= :set

    def submit(_http_client=nil)
      client = _http_client || @backend.as_http_client
      client.send(@form.method, @form.action) do |request|
        request.set_form_data(@pairs, @form.encoding)
      end
    end
  end
end
