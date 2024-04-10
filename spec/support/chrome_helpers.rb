# frozen_string_literal: true

module ChromeHelpers
  def build_chrome_headless_driver(width = 1410, heigth = 768)
    chrome_bin = ENV.fetch('GOOGLE_CHROME_BIN',
                           '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome')
    opts = Selenium::WebDriver::Chrome::Options.new(detach: false, args: ['--headless'],
                                                    binary: chrome_bin)
    d = Selenium::WebDriver.for(:chrome, options: opts)
    d.manage.window.size = Selenium::WebDriver::Dimension.new(width, heigth)
    d
  end
end

RSpec.configure do |config|
  config.include ChromeHelpers
end
