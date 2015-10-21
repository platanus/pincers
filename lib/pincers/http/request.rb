module Pincers::Http
  class Request

    attr_reader :method, :uri, :headers
    attr_accessor :data

    def initialize(_method, _uri)
      @method = _method
      @uri = _uri
      @headers = {}
      @data = nil
    end

    def url
      @uri.to_s
    end

    def native_type
      case @method
      when :get then Net::HTTP::Get
      when :post then Net::HTTP::Post
      when :put then Net::HTTP::Put
      when :delete then Net::HTTP::Delete
      else nil end
    end

    def set_query(_pairs)
      _pairs = Utils.hash_to_pairs(_pairs) if _pairs.is_a? Hash
      @uri.query = Utils.encode_urlencoded(_pairs)
    end

    def set_form_data(_pairs, _encoding = nil)
      _pairs = Utils.hash_to_pairs(_pairs) if _pairs.is_a? Hash
      encoding = default_encoding_for(_pairs)
      encoding = _encoding if !_encoding.nil? && encoding == Utils::FORM_URLENCODED

      if method == :get
        raise EncodingNotSupported, encoding if encoding != Utils::FORM_URLENCODED
        set_query _pairs
      else
        headers['Content-Type'] = encoding

        self.data = case encoding
        when Utils::FORM_URLENCODED
          Utils.encode_urlencoded _pairs
        when Utils::FORM_MULTIPART
          Utils.encode_multipart _pairs
        else
          raise Pincers::MissingFeatureError.new "form encoding: #{_encoding}"
        end
      end
    end

  private

    def default_encoding_for(_pairs)
      has_files  = _pairs.any? { |p| p[1].is_a? IO }
      has_files ? Utils::FORM_MULTIPART : Utils::FORM_URLENCODED
    end

  end
end