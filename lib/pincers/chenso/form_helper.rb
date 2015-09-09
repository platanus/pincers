require "pincers/chenso/html_doc_request"

module Pincers::Chenso

  class FormHelper

    attr_reader :form

    def initialize(_base_url, _form)
      @base_url = _base_url
      @form = _form
    end

    def action
      @action ||= URI.join(@base_url, form[:action]).to_s
    end

    def method
      @method ||= begin
        form[:method] ? form[:method].downcase.to_sym : :get
      end
    end

    def submit(_trigger=nil)
      _trigger = _trigger || {}

      pairs = extract_pairs
      pairs << [_trigger[:name], _trigger[:value]] if _trigger[:name] && _trigger[:value]

      form_action = _trigger[:formaction] ? URI.join(@base_url, _trigger[:formaction]) : action
      form_method = _trigger[:formmethod] ? _trigger[:formmethod].downcase.to_sym : method
      form_encoding = detect_enctype(form_method, _trigger[:formenctype])

      build_request(pairs, form_action, form_method, form_encoding)
    end

  private

    def extract_pairs
      inputs = form.xpath('.//*[@name]')
      inputs.map do |input|

        case input.classify
        when :input_submit, :button, :button_submit
          next nil
        when :input_checkbox, :input_radio
          next nil unless input[:checked]
        end

        value = input[:value]
        next nil if value.nil?

        [input[:name], value]
      end.reject(&:nil?)
    end

    def encode_urlencoded(_pairs)
      _pairs.map { |p| "#{CGI.escape(p[0])}=#{CGI.escape(p[1])}" }.join '&'
    end

    def encode_multipart(_pairs)
      raise Pincers::MissingFeatureError.new :encode_multipart
    end

    def detect_enctype(_method, _override=nil)
      return 'application/x-www-form-urlencoded' if _method == :get
      return 'multipart/form-data' if form_has_files?
      _override || form[:enctype] || 'application/x-www-form-urlencoded'
    end

    def form_has_files?
      !form.at_xpath(".//input[@type='file' and @name]").nil?
    end

    def build_request(_pairs, _action, _method, _encoding)
      encoding = detect_enctype(_method || method, _encoding)

      data = case _encoding
      when 'application/x-www-form-urlencoded'
        encode_urlencoded _pairs
      when 'multipart/form-data'
        encode_multipart _pairs
      else
        nil
      end

      headers = { 'Content-Type' => encoding }

      HtmlDocRequest.new _action, {
        method: _method,
        headers: headers,
        data: data
      }
    end

    def do(_str)
      _str.downcase.to_sym
    end

  end
end