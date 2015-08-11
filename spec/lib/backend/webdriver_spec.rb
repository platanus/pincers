require 'spec_helper'
require 'selenium-webdriver'

describe 'Pincers::Backend::Webdriver' do

  before(:context) {
    @driver = Selenium::WebDriver.for :phantomjs
  }

  after(:context) {
    @driver.quit rescue nl
  }

  let(:browser) { Pincers.for_webdriver @driver }

  describe "goto" do

    it "should navigate to given url" do
      # browser.goto "http://platan.us"
      # expect(browser.uri.host).to eq('platan.us')
    end

  end

  context "when inside a page" do

    before { browser.goto "file://#{FIXTURE_PATH}/complex.html" }

    describe "search" do

      it "should use the given css to retrieve elements" do
        expect(browser.css('ul.bikes li').count).to eq(3)
      end

      it "should return a new search context" do
        expect(browser.css('ul li')).to be_a(Pincers::Core::SearchContext)
      end

      it "should only search in parent context" do
        expect(browser.css('ul.empty').css('li').count).to eq(0)
      end

      context "when :wait option is used" do

        pending "should wait a given condition if required"

        it "should fail with timout error if wait times out" do
          expect { browser.css('.non-existant', wait: :present, timeout: 0.1) }.to raise_error(Pincers::ConditionTimeoutError)
        end

      end

    end

    describe "each" do
      it "should iterate over matching elements, wrapping each element in a new context" do
        count = 0
        browser.css('ul.bikes li').each do |el|
          expect(el).to be_a(Pincers::Core::SearchContext)
          count += 1
        end

        expect(count).to eq(3)
      end
    end

    describe "[]" do

      let(:result) { browser.css('form input') }

      it "should return the element in position N wrapped in search context if numeric index is given" do
        expect(result[1]).to be_a(Pincers::Core::SearchContext)
        expect(result[1].attribute(:type)).to eq('email')
      end

      it "should return the attribute named N of the first element if string is given" do
        expect(result[:type]).to eq('text')
      end

    end

    describe "classes" do
      it "should return every class the first element of the search has" do
        expect(browser.css('p.description').classes).to eq(['history', 'description'])
      end
    end

    describe "text" do
      it "should return the text from the first of matched elements" do
        expect(browser.css('ul.bikes li').text).to eq('GT')
      end
    end

  end

  context "when inside a simple page" do

    before { browser.goto "file://#{FIXTURE_PATH}/simple.html" }

    describe "to_html" do
      it "should properly return the selected elements html" do
        expect(browser.to_html).to eq '<html><head></head><body><ul class="bikes"><li>GT</li><li>Mongoose</li></ul></body></html>'
        expect(browser.css('li').to_html).to eq '<li>GT</li><li>Mongoose</li>'
        expect(browser.css('li').first.to_html).to eq '<li>GT</li>'
      end
    end

  end
end
