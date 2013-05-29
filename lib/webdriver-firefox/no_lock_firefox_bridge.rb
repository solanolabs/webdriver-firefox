module NoLockFirefox
  class NoLockFirefoxBridge < Selenium::WebDriver::Firefox::Bridge
    class FakeLock
      def initialize(*args)
      end
  
      def locked
        yield
      end
    end
  
    class NoLockLauncher < Selenium::WebDriver::Firefox::Launcher
      private
  
      def find_free_port
      end
  
      def socket_lock
        @socket_lock ||= FakeLock.new
      end
    end
  
    def create_launcher(port, profile)
      NoLockLauncher.new Selenium::WebDriver::Firefox::Binary.new, port, profile
    end
  end
end
