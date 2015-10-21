require 'pincers/core/base_factory'
require 'pincers/webdriver/backend'

module Pincers::Webdriver
  class Factory < Pincers::Core::BaseFactory

    DEFAULT_SETUP = {
      page_timeout: 60000
    }

    def load_backend(_options)
      driver = _options.delete(:driver)

      unless driver.is_a? Selenium::WebDriver::Driver
        driver = create_driver driver, _options
      else
        setup_driver driver, _options
      end

      Pincers::Webdriver::Backend.new driver
    end

  private

    def create_driver(_name, _user={})
      setup_options = extract_setup_options _user
      build_options = recommended_settings_for _name
      build_options = apply_custom_options build_options, _user

      driver = Selenium::WebDriver::Driver.for _name, build_options
      setup_fresh_driver driver, setup_options
      driver
    end

    def setup_fresh_driver(_driver, _options)
      _driver.manage.window.resize_to 1280, 1024 # ensure desktop form factor
      setup_driver _driver, DEFAULT_SETUP.merge(_options)
    end

    def setup_driver(_driver, _options)
      _driver.manage.timeouts.implicit_wait = _options[:implicit_timeout] if _options.key? :implicit_timeout
      _driver.manage.timeouts.page_load = _options[:page_timeout] if _options.key? :page_timeout
      _driver.manage.timeouts.script_timeout = _options[:script_timeout] if _options.key? :script_timeout
    end

    def recommended_settings_for(_name)
      case _name
      when :phantomjs
        {
          desired_capabilities: phantomjs_capabilities
        }
      when :chrome
        {
          detach: false, # ensure browser is shut down on exit
          desired_capabilities: chrome_capabilities
        }
      when :firefox
        {
          desired_capabilities: firefox_capabitilies
        }
      else {} end
    end

    def apply_custom_options(_options, _user)
      if _user.key? :proxy
        proxy = _user.delete(:proxy)
        proxy = Selenium::WebDriver::Proxy.new http: proxy, ssl: proxy if proxy.is_a? String
        _options.desired_capabilities.proxy = proxy
      end

      _options.merge _user
    end

    def extract_setup_options(_user)
      [:implicit_timeout, :page_timeout, :script_timeout].inject({}) do |opt, key|
        opt[key] = _user.delete key if _user.key? key
        opt
      end
    end

    def phantomjs_capabilities
      Selenium::WebDriver::Remote::Capabilities.phantomjs({
        'phantomjs.cli.args' => ['--ssl-protocol=any', '--web-security=false', '--ignore-ssl-errors=true', '--load-images=false']
      })
    end

    def chrome_capabilities
      Selenium::WebDriver::Remote::Capabilities.chrome
    end

    def firefox_capabitilies
      Selenium::WebDriver::Remote::Capabilities.firefox
    end

  end
end