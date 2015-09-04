require "spec_helper"
require "pincers/support/cookie_jar"

describe "Pincers::Support::CookieJar" do

  let(:jar) { Pincers::Support::CookieJar.new }
  let(:base_uri) { URI.parse "http://crabfarm.io" }
  let(:internal_uri) { URI.parse "http://crabfarm.io/demo/" }
  let(:subdomain_uri) { URI.parse "http://blog.crabfarm.io" }
  let(:simple_cookie) { "NAME=VALUE;" }
  let(:domain_cookie) { "NAME=VALUE; domain=www.crabfarm.io" }
  let(:other_domain_cookie) { "NAME=VALUE; domain=www.crabtrap.io" }

  describe "set_raw" do

    it "should properly set the cookie domain" do
      expect(jar.set_raw(base_uri, simple_cookie).domain).to eq("crabfarm.io")
      expect(jar.set_raw(internal_uri, simple_cookie).domain).to eq("crabfarm.io")
      expect(jar.set_raw(internal_uri, domain_cookie).domain).to eq("www.crabfarm.io")
      expect(jar.set_raw(internal_uri, other_domain_cookie)).to be nil
    end

    it { expect(jar.set_raw(base_uri, simple_cookie).name).to eq 'NAME' }
    it { expect(jar.set_raw(base_uri, simple_cookie).value).to eq 'VALUE' }

  end

  context "given some already set cookies" do

    before do
      jar.set domain: 'google.com', name: 'lastq', value: 'webscraping'
      jar.set domain: 'blog.crabfarm.io', name: 'session', value: 'somesessiondata'
      jar.set domain: '.crabfarm.io', name: 'session', value: 'othersessiondata'
      jar.set domain: 'crabfarm.io', name: 'session', value: 'othersessiondata', path: '/demo'
    end

    describe "for_origin" do

      it "should return all cookies that match the uri" do
        expect(jar.for_origin(internal_uri).count).to eq 2
        expect(jar.for_origin(base_uri).count).to eq 1
        expect(jar.for_origin(subdomain_uri).count).to eq 2
      end

    end

    describe "set" do

      it "should replace other cookies with same domain and name" do
        expect {
          jar.set domain: 'crabfarm.io', name: 'session', value: 'empty'
        }.not_to change {
          jar.cookies.count
        }
      end

    end

  end

end