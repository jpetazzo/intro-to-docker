<!SLIDE>
# Installing Docker

Docker is easy to install.

It runs on:

* A variety of Linux distributions.
* OS X via a virtual machine.
* Microsoft Windows via a virtual machine.

<!SLIDE>
# Installing Docker on Linux

It can be installed via:

* Distribution supplied packages on virtually all distros.

    (Includes at least: Arch Linux, CentOS, Debian, Fedora, Gentoo,
    openSUSE, RHEL, Ubuntu.)

* Packages supplied by Docker.
* Installation script from Docker.
* Binary download from Docker (it's a single file).

<!SLIDE>
# Installing Docker on your Linux distribution

On Fedora.

    @@@ Sh
    $ sudo yum install docker-io

On CentOS 7.

    @@@ Sh
    $ sudo yum install docker

On Debian and derivatives.

    @@@ Sh
    $ sudo apt-get install docker.io

<!SLIDE>
# Installation script from Docker

You can use the ``curl`` command to install on several platforms.

    @@@ Sh
    $ curl -s https://get.docker.io/ubuntu/ | sudo sh

This currently works on:

* Ubuntu;
* Debian;
* Fedora;
* Gentoo.

<!SLIDE>
# Installing on OS X and Microsoft Windows

Docker doesn't run natively on OS X and Microsoft Windows.

To install Docker on these platforms we run a small virtual machine
using a tool called [Boot2Docker](http://boot2docker.io).

![Boot2Docker](logo.png)

<!SLIDE>
# Docker architecture

* Docker is a client-server application.

**The Docker daemon**

* The Docker server.
* Receives and processes incoming Docker API requests.

**The Docker client**

* Command line tool - the ``docker`` binary.
* Talks to the Docker daemon via the Docker API.

**Docker Hub Registry**

* Public image registry.
* The Docker daemon talks to it via the registry API.

<!SLIDE>
# Test Docker is working

Using the ``docker`` client:

    @@@ Sh
    $ sudo docker version
    Client version: 1.1.1
    Client API version: 1.13
    Go version (client): go1.2.1
    Git commit (client): bd609d2
    Server version: 1.1.1
    Server API version: 1.13
    Go version (server): go1.2.1
    Git commit (server): bd609d2

<!SLIDE center>
# Su-su-sudo

![su-su-sudo](sudo.png)

<!SLIDE>
# The ``docker`` group

**Warning!**

The ``docker`` user is ``root`` equivalent.

It provides ``root`` level access to the host.

You should restrict access to it like you would protect ``root``.

## Add the Docker group

    @@@ Sh
    $ sudo groupadd docker

## Add ourselves to the group

    @@@ Sh
    $ sudo gpasswd -a $USER docker

## Restart the Docker daemon

    @@@ Sh
    $ sudo service docker restart

## Log out

    @@@ Sh
    $ exit

<!SLIDE>
# Hello World again without sudo

    @@@ Sh
    $ docker run ubuntu echo hello world

<!SLIDE>
# Section summary

We've learned how to:

* Install Docker.
* Run Docker without ``sudo``.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Install Docker

1. We've already installed Docker inside our lab environment.

2. Connect to the lab environment.


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Stop, start and restart the Docker daemon

We're going to use the ``service`` command to stop, start and restart
the Docker daemon.

1. Stop the Docker daemon.

        @@@ Sh
        $ service docker stop

2. Start the Docker daemon.

        @@@ Sh
        $ service docker start

3. Restart the Docker daemon.

        @@@ Sh
        $ service docker restart

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Test the Docker client

1. Use the ``docker`` client to confirm the Docker daemon is running.

         @@@ Sh
         $ docker version

2. You should see:

         @@@ Sh
         Client version: 0.11.1
         Client API version: 1.11
         Go version (client): go1.2.1
         Git commit (client): fb99f99
         Server version: 0.11.1
         Server API version: 1.11
         Git commit (server): fb99f99
         Go version (server): go1.2.1
         Last stable version: 0.11.1

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: See the Docker client help

1. Use the ``docker help`` command to see what the Docker client can do.

        @@@ Sh
        $ docker help

2. You should see:

        @@@ Sh
        Usage: docker [OPTIONS] COMMAND [arg...]
        -H=[unix:///var/run/docker.sock]: tcp://host:port to bind/connect to or unix://path/to/socket to use

        A self-sufficient runtime for linux containers.

        Commands:
          attach    Attach to a running container
          build     Build a container from a Dockerfile
        . . .

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Don't need no sudo

1. Create the ``docker`` group.

        @@@ Sh
        $ sudo groupadd docker

2. Add your user to the ``docker`` group.

        @@@ Sh
        $ sudo gpasswd -a $USER docker

3. Restart the Docker daemon.

        @@@ Sh
        $ sudo service docker restart

4. Log out.

        @@@ Sh
        $ exit

5. Login.

        @@@ Sh
        $ ssh ec2-user@yourlabhost
        you@ip.com's password: 

6. Test that Docker works without ``sudo``

        @@@ Sh
        $ docker run ubuntu echo hello world
