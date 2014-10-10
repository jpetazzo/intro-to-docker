<!SLIDE>
# What can we do with Docker API access?

Someone who has access to the Docker API will have full root
privileges on the Docker host.

If you give root privileges to someone, assume that they can do
*anything they like* on the host, including:

* Accessing all data.
* Changing all data.
* Creating new user accounts and changing passwords.
* Installing stealth rootkits.
* Shutting down the machine.

<!SLIDE>
# Accessing the host filesystem

To do that, we will use ``-v`` to expose the host filesystem
inside a container:

    @@@ Sh
    $ docker run -v /:/hostfs ubuntu cat /hostfs/etc/passwd
    ...This shows the content of /etc/passwd on the host...

If you want to explore freely the host filesystem:

    @@@ Sh
    $ docker run -ti -v /:/hostfs -w /hostfs ubuntu bash

<!SLIDE>
# Modifying the host filesystem

Volumes are read-write by default, so let's create a dummy file
on the host filesystem:

    @@@ Sh
    $ docker run -ti -v /:/hostfs ubuntu touch /hostfs/hi-there
    $ ls -l /
    ...You will see the hi-there file, created on the host...

Note: if you are using boot2docker or a remote Docker host,
you won't see the ``hi-there`` file. It will be in the
boot2docker VM, or on the remote Docker host instead.

<!SLIDE>
# Privileged containers

If you start a container with ``--privileged``, it will be able
to access all devices and perform all operations.

For instance, it will be able to access the whole kernel memory 
by reading (and even writing!) ``/dev/kcore``.

A container could also be started with ``--net host`` and
``--privileged`` together, and be able to sniff all the traffic
going in and out of the machine.

<!SLIDE>
# Other harmful operations

We won't explain how to do this (because we don't want you
to break your Docker machines), but with access to the Docker
API, you can:

* Add user accounts.
* Change password of existing accounts.
* Add SSH key authentication to existing accounts.
* Insert kernel modules.
* Run malicious processes and insert special kernel code to hide them.

<!SLIDE>
# What to do?

* Do not expose the Docker API to the general public.
* If you expose the Docker API, secure it with TLS certificates.
* TLS certificates will be presented in the next section.
* Make sure that your users are trained to not give away credentials.

<!SLIDE>
# Security of containers themselves

* "Containers Do Not Contain!"
* Containers themselves do not have security features.
* Security is ensured by a number of other mechanisms.
* We will now review some of those mechanisms.

<!SLIDE>
# Do not run processes as root

* By default, Docker runs everything as root.
* This is a security risk.
* Docker might eventually drop root privileges automatically,
  but until then, you should specify ``USER`` in your Dockerfiles,
  or use ``su`` or ``sudo``.

<!SLIDE>
# Don't colocate security-sensitive containers

* If a container contains security-sensitive information,
  put it on its own Docker host, without other containers.
* Other containers (private development environments,
  non-sensitive applications...) can be put together.


<!SLIDE>
# Run AppArmor or SELinux

* Both of these will provide you with an additional layer of protection if 
  an attacker is able to gain elevated access.

<!SLIDE>
# Learn more about containers and security

* Presentation given at LinuxCon 2014 (Chicago)

http://www.slideshare.net/jpetazzo/docker-linux-containers-lxc-and-security
