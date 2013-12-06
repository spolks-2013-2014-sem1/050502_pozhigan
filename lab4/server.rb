require 'socket'
require '../spolks_lib/XSocket'

include Socket::Constants


port_num, file_address = ARGV
BUFFER_SIZE = 64 * 1024
OOB_CHAR = '!'

open(file_address + '_copy', 'w:binary') do |f|
  server = Xsocket.new(port_num, '')

  received = 0

  server.listen do |client|
    puts 'incoming connection from %s' % client.remote_address.inspect_sockaddr

    trap(:URG) do
      begin
        client.recv(1, Socket::MSG_OOB)
      rescue Exception
        # ignored
      ensure
        puts 'got %s bytes of normal data' % received
      end
    end

    client.fcntl(8, Process.pid) # so we will get sigURG
    while (data = client.read(BUFFER_SIZE)) do
      f.write(data)
      if client.eof?
        puts 'remote closed connection'
        break
      end
      received += data.size
    end
    puts 'Received!!!'
    server.close
  end


end
