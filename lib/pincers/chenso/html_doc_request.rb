require "pincers/support/http_request"

module Pincers::Chenso

  class HtmlDocRequest < Pincers::Support::HttpRequest

    def execute(_client)
      response = super(_client)
      ::Nokogiri::HTML response.body
    end

  end

end