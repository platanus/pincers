require "spec_helper"
require "pincers/chenso/browsing_context"

describe "Pincers::Chenso::BrowsingContext" do

  let(:client) { :dummy }
  let(:service) { Pincers::Chenso::BrowsingContext.new client }

  6.times do |i|
    let("fake_request_#{i}") do
      double('Pincers::Support::HttpRequest', {
        url: "crabfarm.io/fake/#{i}",
        execute: "fake_content_#{i}"
      })
    end
  end

  describe "current_url" do

    it "should return nil by default" do
      expect(service.current_url).to be nil
    end

  end

  describe "document" do

    it "should return nil by default" do
      expect(service.document).to be nil
    end

  end

  describe "push" do

    it "should execute the given request passing the managed client and return result" do
      expect(service.push(fake_request_1)).to eq('fake_content_1')
      expect(fake_request_1).to have_received(:execute).with(client)
    end

  end

  describe "forward" do

    it "should return nil by default" do
      expect(service.forward).to be nil
    end

  end

  describe "back" do

    it "should return nil by default" do
      expect(service.back).to be nil
    end

  end

  context "after som child context have been created" do

    before {
      service.push(fake_request_1)
      service.push(fake_request_2)
      service.push(fake_request_3)
      service.back
      service.load_child('foo')
    }

    describe "get_child" do
      it { expect(service.get_child('foo')).to be_a(Pincers::Chenso::BrowsingContext) }
    end

    describe "navigation methods" do
      it { expect { service.push(fake_request_2) }.to change { service.get_child('foo') }.to nil }
      it { expect { service.back }.to change { service.get_child('foo') }.to nil }
      it { expect { service.forward }.to change { service.get_child('foo') }.to nil }
      it { expect { service.refresh }.to change { service.get_child('foo') }.to nil }
    end

  end

  context "after some requests have been pushed" do

    before {
      service.push(fake_request_1)
      service.push(fake_request_2)
      service.push(fake_request_3)
    }

    describe "document" do

      it { expect(service.document).to eq 'fake_content_3' }

    end

    describe "current_url" do

      it { expect(service.current_url).to eq('crabfarm.io/fake/3') }

    end

    describe "back" do

      it "should navigate to previous requests" do
        expect(service.back(1)).to eq('fake_content_2')
        expect(service.document).to eq('fake_content_2')
        expect(fake_request_2).to have_received(:execute).exactly(2).times
      end

      it "should jump over the given number of steps" do
        expect(service.back(2)).to eq('fake_content_1')
        expect(service.document).to eq('fake_content_1')
        expect(fake_request_1).to have_received(:execute).exactly(2).times
        expect(fake_request_2).to have_received(:execute).exactly(1).times
      end

      it "if the number of steps to jump is more than the previous steps, it should jump to the first step" do
        expect(service.back(10)).to eq('fake_content_1')
        expect(fake_request_1).to have_received(:execute).exactly(2).times
      end

    end

    describe "and then going back" do

      before {
        service.push(fake_request_4)
        service.push(fake_request_5)
        service.back(2)
      }

      describe "current_url" do

        it { expect(service.current_url).to eq('crabfarm.io/fake/3') }

      end

      describe "forward" do

        it "should execute the next step" do
          expect(fake_request_1).to have_received(:execute).exactly(1).times
          expect(service.forward).to eq('fake_content_4')
          expect(service.document).to eq('fake_content_4')
          expect(fake_request_4).to have_received(:execute).exactly(2).times
        end

        it "should execute the last step if number of steps to jump is bigger to the number of remaining steps" do
          expect(service.forward(10)).to eq('fake_content_5')
          expect(fake_request_5).to have_received(:execute).exactly(2).times
        end

      end

    end

  end

end