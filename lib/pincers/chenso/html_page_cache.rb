require 'pincers/chenso/browsing_state'

module Pincers::Chenso
  class HtmlPageCache
    def initialize(_uri, _content)
      @uri =  _uri
      @content = _content
    end

    def fix_uri(_current_state)
      # nothing
    end

    def execute(_client)
      BrowsingState.new @uri, ::Nokogiri::HTML(@content)
    end
  end
end