module Pincers::Chenso

  class HtmlDocCache

    attr_reader :url

    def initialize(_url, _raw_document)
      @url = _url
      @raw_document = _raw_document
    end

    def execute(_client)
      ::Nokogiri::HTML @raw_document
    end

  end
end