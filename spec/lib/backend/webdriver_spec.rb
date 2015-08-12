require 'spec_helper'
require 'selenium-webdriver'

describe 'Pincers::Backend::Webdriver' do

  before(:context) {
    @driver = Selenium::WebDriver.for :phantomjs
  }

  before {
    @driver.get "http://localhost:#{SERVER_PORT}/complex.html"
  }

  after(:context) { @driver.quit rescue nl }

  let(:pincers) { Pincers.for_webdriver @driver }

  it_should_properly_read_the_example
  it_should_properly_handle_the_example_inputs

  describe :css do
    context "when wait :present option is used" do
      pending "should wait a given condition if required"

      it "should fail with timeout error if wait times out" do
        expect { pincers.css('.non-existant', wait: :present, timeout: 0.1) }.to raise_error(Pincers::ConditionTimeoutError)
      end
    end
  end
end
