require 'spec_helper'
require 'pincers/http/client'

describe Pincers::Http::Client do

  before {
    stub_request(:any, "foo.bar").to_return(:body => "helloworld", headers: { 'Set-Cookie' => 'foo=bar' })
    stub_request(:get, "foo.bar").with(:query => {"foo" => "bar"})
    stub_request(:get, "foo.bar/relative")
  }

  let(:host) { "http://localhost:#{SERVER_PORT}" }
  let(:client) { described_class.build_from_options }

  describe "get" do
    it "should send a get request to the provided url and set the current document" do
      client.get("http://foo.bar")
      expect(a_request(:get, "foo.bar")).to have_been_made
      expect(client.content).to eq 'helloworld'
    end

    it "should properly set cookies provided by response" do
      client.get("http://foo.bar")
      expect(client.cookies.first.name).to eq 'foo'
      expect(client.cookies.first.value).to eq 'bar'
    end

    it "should properly send stored cookies" do
      client.set_cookie domain: 'foo.bar', name: 'hello', value: 'world'
      client.get("http://foo.bar")
      expect(a_request(:get, "foo.bar").with(headers: { 'Cookie' => 'hello=world' })).to have_been_made
    end

    it "should properly format data as query string if given" do
      client.get("http://foo.bar", foo: 'bar')
      expect(a_request(:get, "foo.bar?foo=bar")).to have_been_made
    end

    it "fail if a relative request is given" do
      expect { client.get("/relative") }.to raise_error(ArgumentError)
    end
  end

  context "when a previous request was made" do

    before { client.get("http://foo.bar") }

    describe "get" do
      it "should support relative urls" do
        client.get("/relative")
        expect(a_request(:get, "foo.bar/relative")).to have_been_made
      end
    end
  end

  describe "post" do
    it "should send a post request to the provided url" do
      client.post('http://foo.bar', 'somedata')
      expect(a_request(:post, "foo.bar").with(body: 'somedata')).to have_been_made
    end

    it "should properly detect 'urlencoded' when no explicit encoding is given" do
      client.post('http://foo.bar', { foo: 'bar' })

      expect(
        a_request(:post, "foo.bar").with(body: 'foo=bar', headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })
      ).to have_been_made
    end

    it "should properly detect 'urlencoded' when form encoding is used" do
      client.post('http://foo.bar', form: { foo: 'bar' })

      expect(
        a_request(:post, "foo.bar").with(body: 'foo=bar', headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })
      ).to have_been_made
    end

    it "should properly detect 'urlencoded' if explicitly required" do
      client.post('http://foo.bar', urlencoded: { foo: 'bar' })

      expect(
        a_request(:post, "foo.bar").with(body: 'foo=bar', headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })
      ).to have_been_made
    end

    it "should allow the request to be customized" do
      client.post('http://foo.bar', { foo: 'bar' }) do |req|
        req.headers['Content-Type'] = 'text/plain'
      end

      expect(
        a_request(:post, "foo.bar").with(body: 'foo=bar', headers: { 'Content-Type' => 'text/plain' })
      ).to have_been_made
    end
  end

  describe "fork" do
    it "should create a new http client bound to the same session" do
      forked = client.fork(true)
      expect(forked).not_to be client
      expect(forked.session).to be client.session
    end
  end

  context "after fork" do

    let!(:fork) { client.fork }

    describe "join" do
      it "should merge other client cookies" do
        fork.set_cookie domain: 'foo.bar', name: 'hello', value: 'world'
        expect { client.join fork }.to change { client.cookies.count }.by 1
      end
    end
  end

  describe "absolute_uri_for" do
    it "should return an absolute uri using the last request as reference" do
      client.get('http://foo.bar')
      expect(client.absolute_uri_for('/relative').to_s).to eq 'http://foo.bar/relative'
    end
  end

  describe "freeze" do
    it "should make following requests return a new forked client" do
      expect(client.get('http://foo.bar')).to be client
      client.freeze
      expect(client.get('http://foo.bar')).not_to be client
    end
  end

end