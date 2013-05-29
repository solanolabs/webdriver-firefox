require "socket"

class WebDriverPortPool

  class TooManyPortsError < StandardError; end
  class TimeoutError < StandardError; end
  class BindError < StandardError; end

  START_PORT      = 1024+512
  HOST            = "127.0.0.1"
  RELEASE_TIMEOUT = 20
  PORT_INCREMENT  = 2

  def initialize(capacity)
    @last_port     = START_PORT - 1
    @last_port     += ENV.fetch('TDDIUM_TID', 0).to_i * PORT_INCREMENT

    @capacity      = capacity
    @servers       = []
    @running       = []

    bind
  end

  def get
    if @servers.empty?
      STDERR.puts "out of ports, finding next"
      @servers << next_server
    end

    s = @servers.shift
    port = s.addr.fetch(1)
    s.close

    wait_while_listening port
    port
  end

  def release(port)
    raise TooManyPortsError if @servers.size == @capacity
    server = wait_for_server(port)
    @servers << server
  rescue WebDriverPortPool::TimeoutError
    STDERR.puts "timed out while releasing #{port}"
  end

  def stop
    @servers.each { |s|
      begin
        s.close
      rescue IOError
      end
    }
  end

  def close_on_exec
    STDERR.puts "#{self.class}: #{Process.pid} pool closed on exec"
    @servers.each { |s| ChildProcess.close_on_exec s }
  end

  def size
    @servers.size
  end

  private

  def bind
    @servers << next_server until size == @capacity
  end

  def next_server
    max_ports   = @capacity*100
    upper_bound = START_PORT + max_ports
    @last_port += PORT_INCREMENT

    until server = try_bind(@last_port)
      if @last_port > upper_bound
        raise BindError, "unable to find free port within #{START_PORT}..#{upper_bound} tries, last port tried #{@last_port}"
      end

      @last_port += PORT_INCREMENT
    end

    server
  end

  def try_bind(port)
    server_for port
  rescue SocketError, Errno::EADDRINUSE
    # ok
  end

  def server_for(port)
    s = TCPServer.new(HOST, port)
    ChildProcess.close_on_exec s # make sure browsers don't inherit the file descriptors

    s
  end

  def wait_for_server(port)
    wait_until(RELEASE_TIMEOUT) {
      res = try_bind port
      # p `lsof -i TCP:#{port}` unless res

      res
    }
  end

  def wait_while_listening(port)
    wait_until(RELEASE_TIMEOUT) {
      not listening?(port, 5)
    }
  end

  def wait_until(timeout, &blk)
    max_time = Time.now + timeout

    until res = yield
      if Time.now >= max_time
        raise TimeoutError, "timed out"
      else
        sleep 0.1
      end
    end

    res
  end

  def listening?(port, timeout = nil)
    addr = Socket.getaddrinfo(HOST, nil)
    sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)

    if timeout
      secs = Integer(timeout)
      usecs = Integer((timeout - secs) * 1_000_000)
      optval = [secs, usecs].pack("l_2")
      sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
      sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
    end
    sock.connect(Socket.pack_sockaddr_in(port, addr[0][3]))
    sock.close

    true
  rescue => e
    false
  end

end # WebDriverPortPool
