require "spec_helper"
require "pincers/chenso/browsing_manager"

describe "Pincers::Chenso::BrowsingManager" do

  let(:client) { :dummy }
  let(:service) { Pincers::Chenso::BrowsingManager.new client }

  6.times do |i|
    let("fake_request_#{i}") do
      double('Pincers::Support::HttpRequest', {
        url: "crabfarm.io/fake/#{i}",
        execute: "fake_content_#{i}"
      })
    end
  end

end