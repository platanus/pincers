require 'pincers/factories/base'
require 'pincers/backend/nokogiri'

module Pincers::Factories
  class Nokogiri < Base

    def load_backend(_options)
      document = _options.delete(:document)

      unless document.is_a? ::Nokogiri::HTML::Document
        document = ::Nokogiri::HTML document, _options[:url], _options[:encoding], _options[:flags]
      end

      ::Pincers::Backend::Nokogiri.new document
    end

  end
end