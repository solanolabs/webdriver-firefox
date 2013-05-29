require 'socket'

module NoLockFirefox
  class PortPool
    HOST            = "127.0.0.1"
    START_PORT      = 24576

    def initialize(path=nil)
      @path_ports = path
      @path_ports ||= "/tmp/webdriver-firefox.ports.json"
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

    def locked_add(port)
      ok = false
      File.open(@path_ports, File::RDWR|File::CREAT, 0644) {|f|
        f.flock(File::LOCK_EX)
        port_set = f.read
        if port_set.empty? then
          port_set = []
        else
          port_set = JSON.load()
        end
        if port_set.include?(port) then
          ok = false
        else
          port_set.push(port)
          f.rewind
          f.write(port_set.to_json)
          f.flush
          f.truncate(f.pos)
          ok = true
        end
      }

      return ok
    end

    def locked_read
      val = nil
      File.open(@path_ports, "r") {|f|
        f.flock(File::LOCK_SH)
        val = f.read
      }
      return JSON.load(val)
    end
  end
end
