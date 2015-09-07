module Pincers::Support
  class HttpRequest

    attr_reader :url, :method

    def initialize(_url, _options={})
      @url = _url
      @method = _options.fetch(:method, :get)
      @headers = _options.fetch(:headers, {})
      @data = _options[:data]
    end

    def execute(_client)
      case @method
      when :get
        _client.get(@url, {}, @headers)
      when :post
        _client.post(@url, @data, @headers)
      when :put
        _client.put(@url, @data, @headers)
      end
    end

  end
end