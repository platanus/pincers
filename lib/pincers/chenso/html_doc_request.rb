require "pincers/support/http_request"

module Pincers::Chenso

  class HtmlDocRequest < Pincers::Support::HttpRequest

    def execute(_client)
      response = super(_client)
      ::Nokogiri::HTML response.body, url.to_s, extract_encoding(response)
    end

  private

    def extract_encoding(_response)
      content_type = _response['Content-Type']
      if content_type
        charset = /;\s*charset=(.*)$/.match content_type
        return charset[1] if charset
      end

      nil
    end

  end

end