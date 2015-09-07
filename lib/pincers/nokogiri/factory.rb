require "pincers/core/base_factory"
require "pincers/nokogiri/backend"

module Pincers::Nokogiri
  class Factory < Pincers::Core::BaseFactory

    def load_backend(_options)
      document = _options.delete(:document)

      unless document.is_a? ::Nokogiri::HTML::Document
        document = ::Nokogiri::HTML document, _options[:url], _options[:encoding], _options[:flags]
      end

      Pincers::Nokogiri::Backend.new document
    end

  end
end