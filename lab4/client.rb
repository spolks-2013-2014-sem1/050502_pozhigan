require 'socket'
require '../spolks_lib/XSocket'

port_num, host_adr, file_address = ARGV
BUFFER_SIZE = 32 * 1024
TIMEOUT = 1000
OOB_CHAR = '!'


open(file_address, 'r:binary') do |f|
  client = Xsocket.new(port_num, host_adr)

  client.connect do |server|
    counter = 16
    until f.eof?
      begin
        if counter == 0
          puts 'sending 1 byte of OOB data: %s' % OOB_CHAR.inspect
          server.send(OOB_CHAR, Socket::MSG_OOB)
          counter = 32
        else
          server.write(f.read(BUFFER_SIZE))
          counter = counter - 1
        end
      rescue Errno::EPIPE
        puts 'remote closed socket'
        exit
      rescue Interrupt
        puts 'STOPPED'
        exit
      end
      sleep(0.1) # wait some time for comfortable testing
    end
    puts 'Finished'
    client.close
  end
end

