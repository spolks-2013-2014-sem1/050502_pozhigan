require 'socket'
require '../spolks_lib/Constants'

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


  def receive_n_write_to_file(file_name)
    open(file_name + '_copy', 'w:binary') do |f|
      loop do
        reader, _ = IO.select([@socket], nil, nil, TIMEOUT)
        break unless reader
        if (io = reader[0])
          package = io.recv(BUFFER_SIZE)
          break if (package.nil? || package.empty? || package == UDP_END)
          f.write(package)
        end
      end
    end
  end


  def read_file_n_send(file_name)
    open(file_name, 'r:binary') do |f|
      @socket.connect(@sockaddr)
      until f.eof?
        _, writer = IO.select(nil, [@socket], nil, TIMEOUT)
        break unless writer
        if (io = writer[0])
          package = f.read(BUFFER_SIZE)
          if package.nil? || package.empty?
            io.send(UDP_END, 0)
            break
          end
          io.send(package, 0)
        end
      end
    end
  end

  def close
    @socket.close if @socket
  end

end