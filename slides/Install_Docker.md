---
class: title

# Install Docker

![install](install.jpg)
---
## Lesson ~~~SECTION:MAJOR~~~: Installing Docker

### Objectives

At the end of this lesson, you will know:

* How to install Docker.
* When to use `sudo` when running Docker commands.

*Note:* if you were provided with a training VM for a hands-on
tutorial, you can skip this chapter, since that VM already
has Docker installed, and Docker has already been setup to run
without ``sudo``.
---
class: x-extra-details

## Installing Docker

Docker is easy to install.

It runs on:

* A variety of Linux distributions.
* OS X via a virtual machine.
* Microsoft Windows via a virtual machine.

---
class: x-extra-details

## Installing Docker on Linux

It can be installed via:

* Distribution-supplied packages on virtually all distros.

    (Includes at least: Arch Linux, CentOS, Debian, Fedora, Gentoo,
    openSUSE, RHEL, Ubuntu.)

* Packages supplied by Docker.
* Installation script from Docker.
* Binary download from Docker (it's a single file).

---
## Installing Docker with upstream packages

* Preferred method to install Docker on Linux.
* Upstream's packages are more up-to-date than distros'.
* Instructions per distro:
  <br/>https://docs.docker.com/engine/installation/linux/
* Package will be named `docker-engine`.

---
class: x-extra-details

## Installing Docker with distros packages

On Red Hat derivatives (Fedora, CentOS):

    @@@ Sh
    $ sudo yum install docker

On Debian and derivatives:

    @@@ Sh
    $ sudo apt-get install docker.io

---
class: x-extra-details

## Installation script from Docker

You can use the ``curl`` command to install on several platforms:

    @@@ Sh
    $ curl -s https://get.docker.com/ | sudo sh

This currently works on:

* Ubuntu
* Debian
* Fedora
* Gentoo

---
## Installing on OS X and Microsoft Windows

Docker doesn't run natively on OS X or Microsoft Windows.

There are three ways to get Docker on OS X or Windows:

* Using Docker Mac or Docker Windows (recommended);
* Using the Docker Toolbox (formerly recommended);
* Rolling your own with e.g. Parallels, VirtualBox, VMware...

--- 
## Running Docker on OS X and Windows

When you execute `docker version` from the terminal:

* the CLI connects to the Docker Engine over a standard socket,
* the Docker Engine is, in fact, running in a VM,
* ... but the CLI doesn't know or care about that,
* the CLI sends a request using the REST API,
* the Docker Engine in the VM processes the request,
* the CLI gets the response and displays it to you.

All communication with the Docker Engine happens over the API.

This will also allow to use remote Engines exactly as if they were local.

---
## Rolling your own install

* Good luck, you're on your own!
* There is (almost?) no good reason to do that.
* If you want to do something very custom, the Docker Toolbox is probably better anyway.

---
## Using the Docker Toolbox

The Docker Toolbox installs the following components:

* VirtualBox + Boot2Docker VM image (runs Docker Engine)
* Kitematic GUI
* Docker CLI
* Docker Machine
* Docker Compose
* A handful of clever wrappers

---
class: x-extra-details

## About boot2docker

It is a very small VM image (~30 MB).

It runs on most hypervisors and can also boot on actual hardware.

Boot2Docker is not a "lite" version of Docker.

![Boot2Docker](logo.png)

---
## Docker Mac and Docker Windows

* Docker Mac and Docker Windows are newer products
* They let you run Docker without VirtualBox
* They are installed like normal applications (think QEMU, but faster)
* They provide better integration with enterprise VPNs
* They support filesystem sharing through volumes (we'll talk about this later)

Only downside (for now): only one instance at a time; so if you want
to run a full cluster on your local machine, you can fallback on the
Docker Toolbox (it can coexist with Docker Mac/Windows just fine).

---
## Important PSA about security

The ``docker`` user is ``root`` equivalent.

It provides ``root``-level access to the host.

You should restrict access to it like you would protect ``root``.

If you give somebody the ability to access the Docker API, you are giving them full access on the machine.

Therefore, the Docker control socket is (by default) owned by the `docker` group, to avoid unauthorized access on multi-user machines.

If your user is not in the `docker` group, you will need to prefix every command with `sudo`; e.g. `sudo docker version`.

---
class: extra-details

## Reminder ...

*Note:* if you were provided with a training VM for a hands-on
tutorial, you can skip this chapter, since that VM already
has Docker installed, and Docker has already been setup to run
without ``sudo``.

---
class: extra-details

## The ``docker`` group

### Add the Docker group

    @@@ Sh
    $ sudo groupadd docker

### Add ourselves to the group

    @@@ Sh
    $ sudo gpasswd -a $USER docker

### Restart the Docker daemon

    @@@ Sh
    $ sudo service docker restart

### Log out

    @@@ Sh
    $ exit

---
class: extra-details

## Check that Docker works without sudo

    @@@ Sh
    $ docker version
    Client:
     Version:      1.11.1
     API version:  1.23
     Go version:   go1.5.4
     Git commit:   5604cbe
     Built:        Tue Apr 26 23:38:55 2016
     OS/Arch:      linux/amd64

    Server:
     Version:      1.11.1
     API version:  1.23
     Go version:   go1.5.4
     Git commit:   5604cbe
     Built:        Tue Apr 26 23:38:55 2016
     OS/Arch:      linux/amd64


---
## Section summary

We've learned how to:

* Install Docker.
* Run Docker without ``sudo``.

