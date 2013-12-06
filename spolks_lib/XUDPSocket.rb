require 'socket'
require 'Constants'

class XUDPSocket

  def initialize(port, address)
    @socket = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
    @sockaddr = Socket.sockaddr_in(port, address)
    @chunk_size = CHUNK_SIZE
  end

  def chunk_size
    @chunk_size
  end

  def chunk_size=(new_size)
    @chunk_size = new_size
  end

  def bind
    @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    @socket.bind(@sockaddr)
  end

  def connect(&code)
    @socket.connect(@sockaddr)
    begin
      puts 'Connected...'
      code.call(@socket)
    rescue Errno::EPIPE => e
      puts 'Server disconnected' + e.msg
    end
  end


  def send(msg, flags, dst_addr)
    @socket.send(msg, flags, dst_addr)
  end

  def close
    @socket.close if @socket
  end

end