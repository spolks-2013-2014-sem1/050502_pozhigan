require 'socket'

include Socket::Constants


port_num, file_address = ARGV
BUFFER_SIZE = 32 * 1024
OOB_CHAR = '!'

Socket.open(AF_INET, SOCK_STREAM, 0) do |s|
  s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

  s.bind(Socket.sockaddr_in(port_num, ''))
  s.listen(1)

  puts 'Server is listening'

  client_socket_fd, _ = s.sysaccept

  client_socket = Socket.for_fd(client_socket_fd)

  open(file_address, 'r:binary') do |f|
    while (read_data = f.read(BUFFER_SIZE))
      begin
        client_socket.puts(read_data)
        s.send(OOB_CHAR, Socket::MSG_OOB)
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