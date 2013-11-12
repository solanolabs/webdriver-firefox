# This file subject to Apache License 2.0; see LICENSE.txt

module Selenium
  module WebDriver
    module Firefox

      # @api private
      class Binary
        LONG_WAIT_TIMEOUT = 180
        LONG_QUIT_TIMEOUT = 10

        def quit
          return unless @process
          @process.poll_for_exit LONG_QUIT_TIMEOUT
        rescue ChildProcess::TimeoutError
          # ok, force quit
          @process.stop LONG_QUIT_TIMEOUT
        end

        def wait
          @process.poll_for_exit(LONG_WAIT_TIMEOUT) if @process
        end
      end # Binary
    end # Firefox
  end # WebDriver
end # Selenium
