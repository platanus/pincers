require 'spec_helper'
require 'nokogiri'

describe 'Pincers::Factory' do

  describe 'for_webdriver' do

    it "should close connection automatically if block is given" do
      temp = Pincers.for_webdriver :phantomjs do |pincers|
        expect { pincers.url }.not_to raise_error
        pincers
      end

      expect { temp.url }.to raise_error
    end

    it "shouldn't close connection if no block is given" do
      pincers = Pincers.for_webdriver :phantomjs
      expect { pincers.url }.not_to raise_error
      pincers.close
    end

  end

end