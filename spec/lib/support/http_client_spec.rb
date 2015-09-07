require "spec_helper"
require "pincers/support/http_client"

describe "Pincers::Support::HttpClient" do

  let(:client) { Pincers::Support::HttpClient.new }
  let(:custom_client) {
    Pincers::Support::HttpClient.new({
      headers: {
        "User-Agent" => "Imateapot"
      },
      proxy: "crabtrap.io:2020"
    })
  }

  describe "copy" do

    it "should create a new http client with the same proxy, cookies and default header" do
      custom_client.cookies.set(domain: 'somedomain.io', name: 'somecookie', value: 'somevalue')
      copy = custom_client.copy
      expect(copy.proxy).to eq "crabtrap.io:2020"
      expect(copy.default_headers["User-Agent"]).to eq("Imateapot")
      expect(copy.cookies).not_to be client.cookies
      expect(copy.cookies.cookies.first.domain).to eq 'somedomain.io'
    end

  end

  describe "get" do

    it "should send a get request to the server and return the response" do
      r = client.get("http://localhost:#{SERVER_PORT}/echo?text=helloworld")
      expect(r.code).to eq '200'
      expect(r.body).to eq 'helloworld'
    end

    it "should properly set cookies provided by response" do
      client.get("http://localhost:#{SERVER_PORT}/setcookie?name=sessionid&value=helloworld")
      cookie = client.cookies.get('http://localhost', 'sessionid')
      expect(cookie.value).to eq ('helloworld')
    end

    context "when a cookie was set by a previous request" do

      before {
        client.cookies.set({
          domain: 'localhost',
          name: 'sessionid',
          value: 'imateapot'
        })
      }

      it "should send the cookie back to the host" do
        expect {
          client.get("http://localhost:#{SERVER_PORT}/checkcookie?name=sessionid&value=imateapot")
        }.not_to raise_error
      end

    end

  end


end