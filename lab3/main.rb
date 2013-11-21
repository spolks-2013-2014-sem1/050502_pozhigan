require 'socket'

include Socket::Constants

port_num, host_adr, type, file_address = ARGV

case type

when 'server'
    puts 'lol sirvachok'


    file_data = IO.binread(file_address)

    server_socket = Socket.new(AF_INET,SOCK_STREAM,0)
    server_socket.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR,true)

    server_socket.bind(Socket.sockaddr_in(port_num,host_adr))
    server_socket.listen(1)
    client_socket_fd, _ = server_socket.sysaccept

    client_socket = Socket.for_fd(client_socket_fd)

    server_socket.send(file_data,0)

    #client_socket.puts(file_data)

    server_socket.close

when  'client'
    puts 'lol clientik'

    ssocket = Socket.new(AF_INET,SOCK_STREAM,0)
    ssocket.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR,true)

    ssocket.connect(Socket.sockaddr_in(port_num,host_adr))

    #$stdout = IO.write(file_address + '_copy',)
    lol = ssocket.read


    IO.binwrite(file_address + '_copy', lol)
    ssocket.close

else
    puts '  dunno lol'
end


