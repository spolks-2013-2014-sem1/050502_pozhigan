Task #3
=======

TCP file transfer client-server application

Requierments
------------

###Ruby

* Ruby version >= 1.9.3


Getting Started
---------------

Start by using main to listen on a specific port, with the file which is to be transferred through TCP protocol:

    $ ruby main.rb server filename.in 1234

Using a second machine, connect to the listening main process, with output captured into a file:

    $ ruby main.rb client filename.out 1234 localhost

After the file has been transferred, the connection will close automatically.