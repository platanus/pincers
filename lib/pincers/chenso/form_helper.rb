require "pincers/nokogiri/property_helper"
require "pincers/chenso/html_doc_request"

module Pincers::Chenso

  class FormHelper

    attr_reader :form

    def initialize(_form)
      @form = _form
    end

    def action(_base_url)
      URI.join(_base_url, @form[:action]).to_s
    end

    def as_request(_base_url, _enctype=nil)
      encoding = detect_enctype(_enctype)

      data = case encoding
      when 'application/x-www-form-urlencoded'
        encode_urlencoded
      when 'multipart/form-data'
        encode_multipart
      else
        nil
      end

      build_request action(_base_url), encoding, data
    end

    def pairs
      inputs = form.xpath('.//*[@name]')
      inputs.map do |input|
        input = Pincers::Nokogiri::PropertyHelper.new input

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

    def encode_urlencoded
      pairs.map { |p| "#{CGI.escape(p[0])}=#{CGI.escape(p[1])}" }.join '&'
    end

    def encode_multipart
      raise Pincers::MissingFeatureError.new :encode_multipart
    end

  private

    def wrap
      Pincers::Nokogiri::Helpers
    end

    def method
      @method ||= begin
        form[:method].downcase.to_sym rescue :get
      end
    end

    def detect_enctype(_requested)
      return 'application/x-www-form-urlencoded' if method == :get
      return 'multipart/form-data' if form_has_files?
      _requested || form[:enctype] || 'application/x-www-form-urlencoded'
    end

    def form_has_files?
      !form.at_xpath(".//input[@type='file' and @name]").nil?
    end

    def build_request(_url, _encoding, _data)
      HtmlDocRequest.new _url, {
        method: method,
        headers: {
          'Content-Type' => _encoding
        },
        data: _data
      }
    end

  end
end