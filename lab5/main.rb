require '../spolks_lib/XTCPSocket'
require '../spolks_lib/XUDPSocket'

protocol, type, file_name, port, host = ARGV

case protocol
when 'udp'
  case type
  when 'server'
    self.start_udp_server(port, file_name)
  when 'client'
    self.start_udp_client(port, host, file_name)
  end
when 'tcp'
  case type
  when 'server'
    self.start_tcp_server(port, file_name)
  when 'client'
    self.start_tcp_client(port, host, file_name)
  end
end

def start_udp_client(port, host, file_name)
  open(file_name, 'r:binary') do |f|
    client = XUDPSocket.new(port, host)
    client.connect do |server|
      until f.eof?
        _, writer = IO.select(nil, [server], nil, 10)
        break unless writer
        if (io = writer[0])
          package = file.read(BUFFER_SIZE)
          if package.nil? || package.empty?
            io.send(UDP_END, 0)
            break
          end
          io.send(package, 0)
        end
      end
      puts 'Finished'
      client.close
    end
  end
end


# Receive file
def start_udp_server(port, file_name)
  open(file_name + '_copy', 'w:binary') do |f|
    server = XTCPSocket.new(port, '')
    server.bind
    puts 'incoming connection from %s' % client.remote_address.inspect_sockaddr
    loop do
      reader, _ = IO.select([server], nil, nil, TIMEOUT)
      break unless reader
      if (io = reader[0])
        package = io.recv(BUFFER_SIZE)
        break if (package.nil? || package.empty? || package == UDP_END)
        f.write(package)
      end
    end
    server.close
  end
end

# Send file
def start_tcp_client(port, host, file_name)

  open(file_name, 'r:binary') do |f|
    client = XTCPSocket.new(port, host)
    client.connect do |server|
      until f.eof?
        _, writer = IO.select(nil, [server], nil, 10)
        break unless writer
        if (io = writer[0])
          package = file.read(BUFFER_SIZE)
          break if (package.nil? || package.empty?)
          io.send(package, 0)
        end
      end
      puts 'Finished'
      client.close
    end
  end
end


def start_tcp_server(port, file_name)
  open(file_name + '_copy', 'w:binary') do |f|
    server = XTCPSocket.new(port, '')
    server.listen do |client|
      puts 'incoming connection from %s' % client.remote_address.inspect_sockaddr
      loop do
        reader, _ = IO.select([client], nil, nil, TIMEOUT)
        break unless reader
        if (io = reader[0])
          package = io.recv(BUFFER_SIZE)
          break if (package.nil? || package.empty?)
          f.write(package)
        end
      end
      server.close
    end
  end
end


