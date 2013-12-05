# urgent data receiver server
# file: urg_recv1.rb
# usage: urg_recv1.rb <port>
# to be tested with urg_send.rb

require 'socket'

F_SETOWN = 8 # set manual as not defined in Fcntl

port = 4321

trap(:INT) { exit }

puts "waiting for connections on port %d" % port
Socket.open(Socket::AF_INET, Socket::SOCK_STREAM, 0) do |socket|
  socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

  socket.bind(Socket.sockaddr_in(port, ''))
  socket.listen(1)

  # Socket.tcp_server_loop(port) do |socket|
  #  puts "incoming connection from %s" % socket.remote_address.inspect_sockaddr


  trap(:URG) do
    begin
      data = socket.recv(100, Socket::MSG_OOB)
      puts "got %d bytes of urgent data: %s" % [data.size, data]
    rescue Exception => err
      puts err.inspect
    end
  end

  socket.fcntl(F_SETOWN, Process.pid) # so we will get sigURG
  client_socket_fd, _ = socket.sysaccept

  client_socket = Socket.for_fd(client_socket_fd)

  #while data = socket.gets do
  #  if socket.eof?
  #    puts "remote closed connection"
  #    socket.close


  while data = client_socket.gets() do
    if client_socket.eof?
      puts "remote closed connection"
      socket.close
      client_socket.close
      break
    end
    data.chop!
    puts "got %d bytes of normal data: %s" % [data.size, data]
  end

end