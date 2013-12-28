module Selenium
  module WebDriver
    module Firefox

      # @api private
      class Launcher
        def find_free_port
          pool = ::NoLockFirefox::PortPool.new
          @port = pool.find_free_port
        end

        def launch
          find_free_port
          create_profile
          start_silent_and_wait
          start
          connect_until_stable

          self
        end
      end # Launcher
    end # Firefox
  end # WebDriver
end # Selenium
