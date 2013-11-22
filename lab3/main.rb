require 'socket'

include Socket::Constants

port_num, host_adr, type, file_address = ARGV
BUFFER_SIZE = 32 * 1024

case type

when 'server'

    Socket.open(AF_INET,SOCK_STREAM,0) do |s|
      s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

      s.bind(Socket.sockaddr_in(port_num, ''))
      s.listen(1)

      puts 'Server is listening'

      client_socket_fd, _ = s.sysaccept

      client_socket = Socket.for_fd(client_socket_fd)

      open(file_address, 'r:binary') do |f|
        while (read_data = f.read(BUFFER_SIZE))
          begin
            client_socket.write(read_data)
          rescue Errno::ECONNRESET
            puts 'Client disconnected'
            break
          rescue Errno::EPIPE
            puts 'Client disconnected'
            break
          end

        end

        client_socket.close
      end

      puts 'Server finished work'
    end

when  'client'

    Socket.open(AF_INET,SOCK_STREAM,0) do |s|
      s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      s.connect(Socket.sockaddr_in(port_num, host_adr))

      puts 'Client connected'

      open(file_address + '_copy', 'w:binary') do |f|
        begin
          while (received_data = s.read)
            if received_data == ''
              puts 'File transfer finished'
              break
            end
            f.write(received_data)
          end
        rescue Errno::EPIPE
          puts 'Server disconnected'
          break
        end
      end
    end

else
    puts 'i dunno lol'
end


