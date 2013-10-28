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


socket = Socket.new(AF_INET,SOCK_STREAM,0)
socket.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR,true)

socket.bind(Socket.sockaddr_in(args['<port_num>'],args['<host_adr>']))
socket.listen(5)

client_socket = Socket.for_fd(socket.sysaccept)
loop do
  data = client_socket.readline.chomp
  puts "Data received: #{data}"
  client_socket.puts "Data send: #{data} lol"
  if data == "shut up"
    break
  end

end
socket.close