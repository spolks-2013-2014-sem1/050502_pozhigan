require 'socket'
require 'docopt'
include Socket::Constants

doc = <<DOCOPT

Usage:
  #{__FILE__} <port_num> <host_adr>
  #{__FILE__} -h

Options:
  -h            Show this screen.
  <port_num>    Number of port to listen [default: 42000]
  <host_adr>    Host address [default: 127.0.0.1]
DOCOPT

begin
  args = Docopt::docopt(doc)
rescue Docopt::Exit => e
  puts e.message
  exit
end


server_socket = Socket.new(AF_INET,SOCK_STREAM,0)
server_socket.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR,true)

server_socket.bind(Socket.sockaddr_in(args['<port_num>'],args['<host_adr>']))
server_socket.listen(1)
client_socket_fd, _ =  server_socket.sysaccept

client_socket = Socket.for_fd(client_socket_fd)
loop do
  begin
  data = client_socket.readline.chomp
  if data == 'quit'
    break
  end

  rescue
    puts 'Client disconnected' #EOFFError
    server_socket.close
    exit
  end
  puts "Data received: #{data}"
  client_socket.puts "You send: #{data}. \n Type quit for quit :3"

end

server_socket.close