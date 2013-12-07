Task #5
=======

TCP&UDP-on file transfer client-server application

Requierments
------------

###Ruby

* Ruby version >= 1.9.3

Getting Started
---------------

Start by using main to listen on a specific port, with the file which is to be transferred through UDP protocol:

    $ ruby main.rb udp server filename.out 1234

or through TCP protocol:

    $ruby main.rb tcp server filename.out 1234

Using a second machine, connect to the listening main process, with output captured into a file, through UDP protocol:

    $ ruby main.rb udp client filename.in 1234 localhost

 or through TCP protocol:
    $ ruby main.rb tcp client filename.in 1234 localhost

After the file has been transferred, the connection will close automatically.