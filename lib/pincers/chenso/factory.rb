require 'pincers/core/base_factory'
require 'pincers/chenso/backend'
require 'pincers/http/client'

module Pincers::Chenso
  class Factory < Pincers::Core::BaseFactory

    def load_backend(_options)
      _options[:headers] = default_headers.merge! _options.fetch(:headers, {})
      client = Pincers::Http::Client.build_from_options _options
      Pincers::Chenso::Backend.new client
    end

  private

    def default_headers
      {
        'User-Agent' => user_agent
      }
    end

    def user_agent
      "Pincers/#{Pincers::VERSION}"
    end

  end
end