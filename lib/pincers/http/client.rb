require 'forwardable'
require 'pincers/http/utils'
require 'pincers/http/session'
require 'pincers/http/request'
require 'pincers/http/response_document'
require 'pincers/http/errors'

module Pincers::Http
  class Client
    extend Forwardable

    def self.build_from_options(_options = {})
      session = Session.new
      session.proxy = _options[:proxy] if _options.key? :proxy
      session.headers.merge! _options[:headers] if _options.key? :headers
      session.redirect_limit = _options[:redirect_limit] if _options.key? :redirect_limit

      client = self.new session, _options[:document]
      client.freeze if _options[:freeze]
      client
    end

    attr_reader :session, :document, :frozen
    def_delegators :@document, :content_type, :content, :uri

    def initialize(_session, _document={})
      @session = _session
      @document = _document
      @frozen = false
    end

    def freeze
      @frozen = true
    end

    def unfreeze
      @frozen = false
    end

    def cookies
      @session.cookie_jar.cookies
    end

    def set_cookie(_cookie)
      if _cookie.is_a? Hash
        _cookie = Cookie.new(_cookie[:name], _cookie[:value], _cookie[:domain], _cookie[:path])
      end

      @session.cookie_jar.set _cookie
    end

    def get(_url, _query = nil, &_block)
      request = build_request :get, _url
      request.set_query _query unless _query.nil?
      _block.call request unless _block.nil?
      perform_in_session request
    end

    def post(_url, _data = nil, &_block)
      request = build_request :post, _url
      load_data_in_request request, _data unless _data.nil?
      _block.call request unless _block.nil?
      perform_in_session request
    end

    def put(_url, _data = nil, &_block)
      request = build_request :put, _url
      load_data_in_request request, _data unless _data.nil?
      _block.call request unless _block.nil?
      perform_in_session request
    end

    def delete(_url, &_block)
      request = build_request :delete, _url
      _block.call request unless _block.nil?
      perform_in_session request
    end

    def fork(_keep_session = false)
      fork_session = _keep_session ? @session : @session.clone
      self.class.new fork_session, @document
    end

    def join(_other_client)
      @session.sync _other_client.session
    end

    def absolute_uri_for(_url)
      uri = _url.is_a?(URI) ? _url : Utils.parse_uri(_url)
      if uri.relative?
        raise ArgumentError, 'Absolute url was required' if @document.nil?
        uri = URI.join(@document.uri, uri)
      end
      uri
    end

  private

    SUPPORTED_MODES = [:form, :urlencoded, :multipart]

    def build_request(_type, _url)
      Request.new _type, absolute_uri_for(_url)
    end

    def load_data_in_request(_request, _data)
      if _data.is_a? Hash
        mode = :form
        if _data.keys.length == 1 and SUPPORTED_MODES.include? _data.keys.first
          mode = _data.keys.first
          _data = _data[mode]
        end

        case mode
        when :form
          _request.set_form_data _data
        when :urlencoded
          _request.set_form_data _data, Utils::FORM_URLENCODED
        when :multipart
          _request.set_form_data _data, Utils::FORM_MULTIPART
        end
      else
        _request.data = _data.to_s
      end
    end

    def perform_in_session(_request)
      begin
        new_document = ResponseDocument.new @session.perform _request
      rescue
        @document = nil unless frozen
        raise
      end

      if frozen
        self.class.new @session, @document
      else
        @document = new_document
        self
      end
    end
  end
end
