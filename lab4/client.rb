require 'socket'

include Socket::Constants


port_num, host_adr, file_address = ARGV
BUFFER_SIZE = 32 * 1024
OOB_CHAR = '!'

Socket.open(AF_INET, SOCK_STREAM, 0) do |s|
  s.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
  s.connect(Socket.sockaddr_in(port_num, host_adr))

  trap(:URG) do

    data = s.recv(100, Socket::MSG_OOB)
    puts "got urgent %s" %data
    readline

  end

  trap("URG") do
    begin
      data = s.recv(100, Socket::MSG_OOB)
      puts "got urgent %s" %data
      readline
    rescue Exception => err
      puts err.inspect
    end
  end

  puts 'Client connected'

  s.fcntl(8, Process.pid)
  open(file_address + '_copy', 'w:binary') do |f|
    begin
      while (received_data = s.gets)
        if (received_data == '')
          puts 'File transfer finished'
          break
        end
        puts 'lol'
        f.write(received_data)
      end
    rescue Errno::EPIPE
      puts 'Server disconnected'
      break
    end
  end
end