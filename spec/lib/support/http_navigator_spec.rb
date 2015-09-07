require "spec_helper"
require "pincers/support/http_navigator"

describe "Pincers::Support::HttpNavigator" do

  let(:client) { :dummy }
  let(:service) { Pincers::Support::HttpNavigator.new client }

  6.times do |i|
    let("fake_request_#{i}") do
      double('Pincers::Support::HttpRequest', {
        url: "crabfarm.io/fake/#{i}",
        execute: "fake_content_#{i}"
      })
    end
  end

  describe "current_url" do

    it "should return current url" do
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
      expect(service.forward).to eq(nil)
    end

  end

  describe "back" do

    it "should return nil by default" do
      expect(service.back).to eq(nil)
    end

  end

  context "after some requests have been pushed" do

    before {
      service.push(fake_request_1)
      service.push(fake_request_2)
      service.push(fake_request_3)
    }

    describe "current_url" do

      it { expect(service.current_url).to eq('crabfarm.io/fake/3') }

    end

    describe "back" do

      it "should navigate to previous requests" do
        expect(service.back(1)).to eq('fake_content_2')
        expect(fake_request_2).to have_received(:execute).exactly(2).times
      end

      it "should jump over the given number of steps" do
        expect(service.back(2)).to eq('fake_content_1')
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