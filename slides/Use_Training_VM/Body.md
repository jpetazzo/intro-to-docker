<!SLIDE>
# Your training Virtual Machine

This section assumes that you are following this course as part of
an official Docker training or workshop, and have been given credentials
to connect to your own private Docker VM.

This VM has been created specifically for you, just before the training.

It comes pre-installed with the latest and shiniest version of Docker,
as well as some useful tools.

It will stay up and running for the whole training, but it will be destroyed
shortly after the training.


<!SLIDE>
# Connecting to your Virtual Machine

You need an SSH client.

* On OS X, Linux, and other UNIX systems, just use `ssh`:

        @@@ Sh
        $ ssh <login>@<ip-address>

* On Windows, if you don't have an SSH client, you can download Putty
  from www.putty.org.

<!SLIDE>
# Checking your Virtual Machine

Once logged in, make sure that you can run a basic Docker command:

    @@@ Sh
    $ docker version
    Client version: 1.4.1
    Client API version: 1.16
    Go version (client): go1.3.3
    Git commit (client): 5bc2ff8
    OS/Arch (client): linux/amd64
    Server version: 1.4.1
    Server API version: 1.16
    Go version (server): go1.3.3
    Git commit (server): 5bc2ff8

* If this doesn't work, raise your hand so that an instructor can assist you!
