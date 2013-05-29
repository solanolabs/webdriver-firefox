module Selenium
  module WebDriver
    class Driver
      class << self
        def for(browser, opts = {})
          listener = opts.delete(:listener)

          bridge = case browser
                   when :firefox, :ff
                     Firefox::Bridge.new(opts)
                   when :firefox_tddium
                     opts[:port] = port
                     ::NoLockFirefox::NoLockFirefoxBridge::Bridge.new(opts)
                   when :remote
                     Remote::Bridge.new(opts)
                   when :ie, :internet_explorer
                     IE::Bridge.new(opts)
                   when :chrome
                     Chrome::Bridge.new(opts)
                   when :android
                     Android::Bridge.new(opts)
                   when :iphone
                     IPhone::Bridge.new(opts)
                   when :opera
                     Opera::Bridge.new(opts)
                   when :phantomjs
                     PhantomJS::Bridge.new(opts)
                   when :safari
                     Safari::Bridge.new(opts)
                   else
                     raise ArgumentError, "unknown driver: #{browser.inspect}"
                   end

          bridge = Support::EventFiringBridge.new(bridge, listener) if listener

          new(bridge)
        end
      end
    end
  end
end
