require "spec_helper"
require "pincers/http/utils"

describe Pincers::Http::Utils do

  let(:srv) { described_class }

  describe 'encode_urlencoded' do
    it { expect(srv.encode_urlencoded({})).to eq("") }
    it { expect(srv.encode_urlencoded({ foo: 'bar' })).to eq("foo=bar") }
    it { expect(srv.encode_urlencoded({ foo: 'bar', hello: 'world' })).to eq("foo=bar&hello=world") }
    it { expect(srv.encode_urlencoded({ foo: '=bar' })).to eq("foo=%3Dbar") }
    it { expect(srv.encode_urlencoded([['foo','bar'],['hello','world']])).to eq("foo=bar&hello=world") }
    it { expect(srv.encode_urlencoded({ foo: 'bar', hello: ['earth', 'mars'] })).to eq("foo=bar&hello[]=earth&hello[]=mars") }
    it { expect(srv.encode_urlencoded({ foo: 'bar', hello: { 'earth' => 1, 'mars' => 0 } })).to eq("foo=bar&hello.earth=1&hello.mars=0") }
  end

  describe 'encode_multipart', skip: true do
  end
end