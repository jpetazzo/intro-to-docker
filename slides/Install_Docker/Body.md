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

* Distribution-supplied packages on virtually all distros.

    (Includes at least: Arch Linux, CentOS, Debian, Fedora, Gentoo,
    openSUSE, RHEL, Ubuntu.)

* Packages supplied by Docker.
* Installation script from Docker.
* Binary download from Docker (it's a single file).

<!SLIDE>
# Installing Docker with upstream packages

* Preferred method.
* Upstream's packages are more up-to-date than distros'.
* Instructions per distro:
  <br/>https://docs.docker.com/engine/installation/linux/
* Package will be named `docker-engine`.

<!SLIDE>
# Installing Docker with distros packages

On Red Hat derivatives (Fedora, CentOS):

    @@@ Sh
    $ sudo yum install docker

On Debian and derivatives:

    @@@ Sh
    $ sudo apt-get install docker.io

<!SLIDE>
# Installation script from Docker

You can use the ``curl`` command to install on several platforms:

    @@@ Sh
    $ curl -s https://get.docker.com/ | sudo sh

This currently works on:

* Ubuntu
* Debian
* Fedora
* Gentoo

<!SLIDE>
# Installing on OS X and Microsoft Windows

Docker doesn't run natively on OS X or Microsoft Windows.

We recommend to use the Docker Toolbox, which installs
the following components:

* VirtualBox + Boot2Docker VM image (runs Docker Engine)
* Kitematic GUI
* Docker CLI
* Docker Machine
* Docker Compose
* A handful of clever wrappers

<!SLIDE> 
# Running Docker on OS X and Windows

When you execute `docker version` from the terminal:

* the CLI prepares a request for the REST API,
* environment variables tell the CLI where to send the request,
* the request goes to the Boot2Docker VM in VirtualBox,
* the Docker Engine in the VM processes the request.

All communication with the Docker Engine happens over the API.

This will also allow to use remote Engines exactly as if they were local.

<!SLIDE>
# Aboout boot2docker

It is a very small VM image (~30 MB).

It runs on most hypervisors and can also boot on actual hardware.

Boot2Docker is not a "lite" version of Docker.

![Boot2Docker](logo.png)

<!SLIDE>
# Check that Docker is working

Using the ``docker`` client:

    @@@ Sh
    $ docker version
    Client:
     Version:      1.9.0
     API version:  1.21
     Go version:   go1.4.2
     Git commit:   76d6bc9
     Built:        Tue Nov  3 17:29:38 UTC 2015
     OS/Arch:      linux/amd64

    Server:
     Version:      1.9.0
     API version:  1.21
     Go version:   go1.4.2
     Git commit:   76d6bc9
     Built:        Tue Nov  3 17:29:38 UTC 2015
     OS/Arch:      linux/amd64


<!SLIDE center>
# Su-su-sudo

![su-su-sudo](sudo.png)

<!SLIDE>
# Important PSA about security

The ``docker`` user is ``root`` equivalent.

It provides ``root``-level access to the host.

You should restrict access to it like you would protect ``root``.

If you give somebody the ability to access the Docker API, you are giving them full access on the machine.

Therefore, the Docker control socket is (by default) owned by the `docker` group, to avoid unauthorized access on multi-user machines.

<!SLIDE>
# Reminder ...

*Note:* if you were provided with a training VM for a hands-on
tutorial, you can skip this chapter, since that VM already
has Docker installed, and Docker has already been setup to run
without ``sudo``.

<!SLIDE>
# The ``docker`` group

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
# Check that Docker works without sudo

    @@@ Sh
    $ docker version
    Client:
     Version:      1.9.0
     API version:  1.21
     Go version:   go1.4.2
     Git commit:   76d6bc9
     Built:        Tue Nov  3 17:29:38 UTC 2015
     OS/Arch:      linux/amd64

    Server:
     Version:      1.9.0
     API version:  1.21
     Go version:   go1.4.2
     Git commit:   76d6bc9
     Built:        Tue Nov  3 17:29:38 UTC 2015
     OS/Arch:      linux/amd64

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
         Client version: 1.5.0
         Client API version: 1.17
         Go version (client): go1.4.1
         Git commit (client): a8a31ef
         OS/Arch (client): linux/amd64
         Server version: 1.5.0
         Server API version: 1.17
         Go version (server): go1.4.1
         Git commit (server): a8a31ef

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
        $ docker version
