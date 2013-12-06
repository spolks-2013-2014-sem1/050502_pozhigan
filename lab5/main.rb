require '../spolks_lib/XTCPSocket'
require '../spolks_lib/XUDPSocket'

protocol, type, file_name, port, host = ARGV

case protocol
when 'udp'
  case type
  when 'server'
    server = XUDPSocket.new(port, '')
    server.bind
    server.receive_n_write_to_file(file_name)
    server.close
  when 'client'
    client = XUDPSocket.new(port, host)
    client.read_file_n_send(file_name)
    client.close
  else
    puts 'i dunno lol'
  end
when 'tcp'
  case type
  when 'server'
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
  when 'client'
    open(file_name, 'r:binary') do |f|
      client = XTCPSocket.new(port, host)
      client.connect do |server|
        until f.eof?
          _, writer = IO.select(nil, [server], nil, 10)
          break unless writer
          if (io = writer[0])
            package = f.read(BUFFER_SIZE)
            break if (package.nil? || package.empty?)
            io.send(package, 0)
          end
        end
        puts 'Finished'
        client.close
      end
    end
  else
    puts 'i dunno lol'
  end
else
  puts 'i dunno lol'
end