require 'socket'

include Socket::Constants

port_num, host_adr, type, file_address = ARGV
BUFFER_SIZE = 32 * 1024

case type

when 'server'
    puts 'lol sirvachok'

    Socket.open(AF_INET,SOCK_STREAM,0) { |s|
      s.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR,true)

      s.bind(Socket.sockaddr_in(port_num,''))
      s.listen(5)
      client_socket_fd, _ = s.sysaccept

      client_socket = Socket.for_fd(client_socket_fd)

      open(file_address, 'r:binary') { |f|
        while read_data = f.read(BUFFER_SIZE)
          client_socket.write(read_data)
        end
      }
    }

when  'client'
    puts 'lol clientik'

    Socket.open(AF_INET,SOCK_STREAM,0) { |s|
      s.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR,true)
      s.connect(Socket.sockaddr_in(port_num,host_adr))

      open(file_address + '_copy', 'w:binary') { |f|
        while received_data = s.read
          f.write(received_data)
        end
      }

    }

else
    puts '  dunno lol'
end


