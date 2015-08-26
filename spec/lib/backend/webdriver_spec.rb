require 'spec_helper'
require 'selenium-webdriver'

describe 'Pincers::Backend::Webdriver' do

  before(:context) {
    @driver = Pincers.for_webdriver(:phantomjs).document
  }

  before {
    @driver.switch_to.default_content
    @driver.get "http://localhost:#{SERVER_PORT}/index.html"
  }

  after(:context) { @driver.quit rescue nil }

  let(:pincers) { Pincers.for_webdriver @driver }

  it_should_properly_navigate_through_example
  it_should_properly_read_the_example
  it_should_properly_enter_data_in_example
  it_should_properly_handle_frames_in_example
  it_should_properly_handle_dynamic_markup

  describe 'close' do
    it "should properly close the driver connection" do
      pincers = Pincers.for_webdriver(:phantomjs)
      expect { pincers.document.current_url }.not_to raise_error
      pincers.close
      expect { pincers.document.current_url }.to raise_error(Errno::ECONNREFUSED)
    end
  end

  describe 'wait' do
    context "when wait :present option is used" do
      it "should fail with timeout error if wait times out" do
        expect { pincers.css('.non-existant').wait(:present, timeout: 0.1) }.to raise_error(Pincers::ConditionTimeoutError)
      end
    end
  end
end
