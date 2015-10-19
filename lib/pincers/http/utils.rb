module Pincers::Http
  module Utils
    extend self

    FORM_URLENCODED = 'application/x-www-form-urlencoded'
    FORM_MULTIPART = 'multipart/form-data'

    def encode_urlencoded(_pairs)
      _pairs = hash_to_pairs _pairs if _pairs.is_a? Hash
      _pairs.map { |p| "#{p[0]}=#{CGI.escape(p[1])}" }.join '&'
    end

    def encode_multipart(_pairs)
      raise Pincers::MissingFeatureError.new :encode_multipart
    end

    def hash_to_pairs(_hash)
      pair_recursive [], _hash
    end

    def parse_uri(_uri)
      URI.parse _uri
    end

  private

    def pair_recursive(_pairs, _data, _prefix = nil)
      _data.each do |key, value|
        key = "#{_prefix}.#{key}" if _prefix
        case value
        when Hash
          pair_recursive _pairs, value, key
        when Array
          key = "#{key}[]"
          value.each { |item| _pairs << [key, item.to_s] }
        else
          _pairs << [key.to_s, value.to_s]
        end
      end
      _pairs
    end
  end
end