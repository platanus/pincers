require 'pincers/http/utils'

module Pincers::Core::Replicas
  class Link

    attr_reader :ref

    def initialize(_backend, _element)
      @backend = _backend
      @ref = Pincers::Http::Utils.parse_uri _backend.extract_element_attribute(_element, :href)
    end

    def fetch(_http_client=nil)
      client = _http_client || @backend.as_http_client
      client.get(@ref)
    end
  end
end
