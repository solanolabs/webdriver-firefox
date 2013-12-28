# Copyright (c) 2013 Solano Labs All Rights Reserved

require 'socket'

module NoLockFirefox
  class PortPool
    HOST            = "127.0.0.1"
    START_PORT      = 24576

    def initialize
      @random = Random.new
    end

    def find_free_port
      probed = nil

      tid = ENV.fetch('TDDIUM_TID', 0).to_i

      range = 256*tid
      index = @random.rand(256)
      limit = START_PORT+256*(tid+1)

      timeout = Time.now+90

      while Time.now < timeout do
        port = START_PORT+range+index
        while port < limit do
          probed = probe_port(port)
          if probed then
            probed.close
            return port
          end
          port += 1
	  Kernel.sleep(0.1)
        end
      end

      raise "unable to find open port in reasonable time"
    end

    def probe_port(port)
      begin
        s = TCPServer.new(HOST, port)
        s.close_on_exec = true
#        ChildProcess.close_on_exec s
        return s
      rescue SocketError, Errno::EADDRINUSE => e
        return nil
      end
    end
  end
end
