require 'spec_helper'
require 'pincers/http/cookie_jar'

describe Pincers::Http::CookieJar do

  let(:jar) { described_class.new }
  let(:base_uri) { URI.parse "http://crabfarm.io" }
  let(:internal_uri) { URI.parse "http://crabfarm.io/demo/" }
  let(:subdomain_uri) { URI.parse "http://blog.crabfarm.io" }
  let(:similar_uri) { URI.parse "http://thecrabfarm.io" }
  let(:simple_cookie) { "NAME=VALUE;" }
  let(:domain_cookie) { "NAME=VALUE; domain=blog.crabfarm.io;" }
  let(:other_domain_cookie) { "NAME=VALUE; domain=www.crabtrap.io" }
  let(:cookie_w_comma) { "FOO=BAR, NAME=VALUE; Expires=Thu, 01-Jan-1970 00:00:10 GMT" }

  describe "set_raw" do

    it "should properly set the cookie domain" do
      expect(jar.set_raw(base_uri, simple_cookie).domain).to eq 'crabfarm.io'
      expect(jar.set_raw(internal_uri, simple_cookie).domain).to eq 'crabfarm.io'
      expect(jar.set_raw(subdomain_uri, domain_cookie).domain).to eq 'blog.crabfarm.io'
      expect(jar.set_raw(internal_uri, domain_cookie)).to be nil
      expect(jar.set_raw(internal_uri, other_domain_cookie)).to be nil
    end

    it { expect(jar.set_raw(base_uri, simple_cookie).name).to eq 'NAME' }
    it { expect(jar.set_raw(base_uri, simple_cookie).value).to eq 'VALUE' }

  end

  describe "set_from_header" do
    it { expect(jar.set_from_header(base_uri, cookie_w_comma).count).to eq 2 }
    it { expect(jar.set_from_header(base_uri, cookie_w_comma).last.name).to eq 'NAME' }
  end

  context "given some already set cookies" do

    before do
      jar.set Pincers::Http::Cookie.new('lastq', 'webscraping', 'google.com', '/')
      jar.set Pincers::Http::Cookie.new('session','somesessiondata', 'blog.crabfarm.io', '/')
      jar.set Pincers::Http::Cookie.new('session', 'othersessiondata', '.crabfarm.io', '/')
      jar.set Pincers::Http::Cookie.new('session', 'othersessiondata', 'crabfarm.io', '/demo')
    end

    describe "for_origin" do

      it "should return all cookies that match the uri" do
        expect(jar.for_origin(internal_uri).count).to eq 2
        expect(jar.for_origin(base_uri).count).to eq 1
        expect(jar.for_origin(subdomain_uri).count).to eq 2
        expect(jar.for_origin(similar_uri).count).to eq 0
      end

    end

    describe "set" do

      it "should replace other cookies with same domain and name" do
        expect {
          jar.set Pincers::Http::Cookie.new('session', 'empty', '.crabfarm.io', '/')
        }.not_to change {
          jar.cookies.count
        }
      end

    end
  end
end