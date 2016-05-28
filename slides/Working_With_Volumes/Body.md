<!SLIDE>
# Working with Volumes

Docker volumes can be used to achieve many things, including:

* Bypassing the copy-on-write system to obtain native disk I/O performance.
* Bypassing copy-on-write to leave some files out of ``docker commit``.
* Sharing a directory between multiple containers.
* Sharing a directory between the host and a container.
* Sharing a *single file* between the host and a container.

<!SLIDE>
# Volumes are special directories in a container

Volumes can be declared in two different ways.

* Within a ``Dockerfile``, with a ``VOLUME`` instruction.

        @@@ docker
        VOLUME /uploads

* On the command-line, with the ``-v`` flag for ``docker run``.

        @@@ Sh
        $ docker run -d -v /uploads myapp

In both cases, ``/uploads`` (inside the container) will be a volume.

<!SLIDE printonly>
# Volumes bypass the copy-on-write system

Volumes act as passthroughs to the host filesystem.

* The I/O performance on a volume is exactly the same as I/O performance
  on the Docker host.
* When you ``docker commit``, the content of volumes is not brought into
  the resulting image.
* If a ``RUN`` instruction in a ``Dockerfile`` changes the content of a
  volume, those changes are not recorded neither.
* If a container is started with the ``--read-only`` flag, the volume
  will still be writable (unless the volume is a read-only volume).

<!SLIDE printonly>
# Volumes can be shared across containers

You can start a container with *exactly the same volumes* as another one.

The new container will have the same volumes, in the same directories.

They will contain exactly the same thing, and remain in sync.

Under the hood, they are actually the same directories on the host anyway.

This is done using the ``--volumes-from`` flag for ``docker run``.

    @@@ Sh
    $ docker run -it --name alpha -v /var/log ubuntu bash
    root@99020f87e695:/# date >/var/log/now

In another terminal, let's start another container with the same volume.

    @@@ Sh
    $ docker run --volumes-from alpha ubuntu cat /var/log/now
    Fri May 30 05:06:27 UTC 2014

<!SLIDE>
# Volumes exist independently of containers

If a container is stopped, its volumes still exist and are available.

Since Docker 1.9, we can see all existing volumes and manipulate them:

    @@@ Sh
    $ docker volume ls
    DRIVER              VOLUME NAME
    local               5b0b65e4316da67c2d471086640e6005ca2264f3...
    local               pgdata-prod
    local               pgdata-dev
    local               13b59c9936d78d109d094693446e174e5480d973...

Some of those volume names were explicit (pgdata-prod, pgdata-dev).

The others (the hex IDs) were generated automatically by Docker.


<!SLIDE printonly>
# Data containers (before Engine 1.9)

A *data container* is a container created for the sole purpose of referencing
one (or many) volumes.

It is typically created with a no-op command:

    @@@ Sh
    $ docker run --name files -v /var/www busybox true
    $ docker run --name logs -v /var/log busybox true

* We created two data containers.
* They are using the ``busybox`` image, a tiny image.
* We used the command ``true``, possibly the simplest command in the world!
* We named each container to reference them easily later.

<!SLIDE printonly>
# Using data containers

Data containers are used by other containers thanks to ``--volumes-from``.

Consider the following (fictitious) example, using the previously created volumes:

    @@@ Sh
    $ docker run -d --volumes-from files --volumes-from logs webserver
    $ docker run -d --volumes-from files ftpserver
    $ docker run -d --volumes-from logs lumberjack

* The first container runs a webserver, serving content from ``/var/www``
  and logging to ``/var/log``.
* The second container runs a FTP server, allowing to upload content to the
  same ``/var/www`` path.
* The third container collects the logs, and sends them to logstash, a log
  storage and analysis system, using the lumberjack protocol.

<!SLIDE>
# Named volumes (since Engine 1.9)

* We can now create and manipulate volumes as first-class concepts.
* Volumes can be created without a container, then used in multiple containers.

Let's create a volume directly.

    @@@ Sh
    $ docker volume create --name=website
    website

Volumes are not anchored to a specific path.

<!SLIDE>
# Using our named volumes

* Volumes are used with the `-v` option.
* When a host path does not contain a /, it is considered to be a volume name.

Let's start a web server using the two previous volumes.

    @@@ Sh
    $ docker run -d -p 8888:80 \
             -v website:/usr/share/nginx/html \
             -v logs:/var/log/nginx \
             nginx

Check that it's running correctly:

    @@@ Sh
    $ curl localhost:8888
    <!DOCTYPE html>
    ...
    <h1>Welcome to nginx!</h1>
    ...

<!SLIDE>
# Using a volume in another container

* We will make changes to the volume from another container.
* In this example, we will run a text editor in the other container, but this could be a FTP server, a WebDAV server, a Git receiver...

Let's start another container using the `website` volume.

    @@@ Sh
    $ docker run -v website:/website -w /website -ti alpine vi index.html

Make changes, save, and exit.

Then run `curl localhost:8888` again to see your changes.


<!SLIDE>
# Managing volumes explicitly

In some cases, you want a specific directory on the host to be mapped
inside the container:

* You want to manage storage and snapshots yourself.

    (With LVM, or a SAN, or ZFS, or anything else!)

* You have a separate disk with better performance (SSD) or resiliency (EBS)
  than the system disk, and you want to put important data on that disk.

* You want to share your source directory between your host (where the
  source gets edited) and the container (where it is compiled or executed).

Wait, we already met the last use-case in our example development workflow!
Nice.

    @@@ Sh
    $ docker run -d -v /path/on/the/host:/path/in/container image ...


<!SLIDE printonly>
# Sharing a directory between the host and a container

The previous example would become something like this:

    @@@ Sh
    $ mkdir -p /mnt/files /mnt/logs
    $ docker run -d -v /mnt/files:/var/www -v /mnt/logs:/var/log webserver
    $ docker run -d -v /mnt/files:/home/ftp ftpserver
    $ docker run -d -v /mnt/logs:/var/log lumberjack

Note that the paths must be absolute.

Those volumes can also be shared with ``--volumes-from``.

<!SLIDE printonly>
# Migrating data with `--volumes-from`

The `--volumes-from` option tells Docker to re-use all the volumes
of an existing container.

* Scenario: migrating from Redis 2.8 to Redis 3.0.
* We have a container (`myredis`) running Redis 2.8.
* Stop the `myredis` container.
* Start a new container, using the Redis 3.0 image, and the `--volumes-from` option.
* The new container will inherit the data of the old one.
* Newer containers can use `--volumes-from` too.

<!SLIDE printonly>
# Data migration in practice

Let's create a Redis container.

    @@@ Sh
    $ docker run -d --name redis28 redis:2.8

Connect to the Redis container and set some data.

    @@@ Sh
    $ docker run -ti --link redis28:redis alpine telnet redis 6379

Issue the following commands:

    @@@ Sh
    SET counter 42
    INFO server
    SAVE
    QUIT

<!SLIDE printonly>
# Upgrading Redis

Stop the Redis container.

    @@@ Sh
    $ docker stop redis28

Start the new Redis container.

    @@@ Sh
    $ docker run -d --name redis30 --volumes-from redis28 redis:3.0

<!SLIDE printonly>
# Testing the new Redis

Connect to the Redis container and see our data.

    @@@ Sh
    docker run -ti --link redis30:redis alpine telnet redis 6379

Issue a few commands.

    @@@ Sh
    GET counter
    INFO server
    QUIT

<!SLIDE>
# What happens when you remove containers with volumes?

* With Engine versions prior 1.9, volumes would be *orphaned* when the last container referencing them is destroyed.
* Orphaned volumes are not deleted, but you cannot access them.

    (Unless you do some serious archaeology in `/var/lib/docker`.)

* Since Engine 1.9, orphaned volumes can be listed with `docker volume ls` and mounted to containers with `-v`.

Ultimately, _you_ are the one responsible for logging,
monitoring, and backup of your volumes.

<!SLIDE printonly>
# Checking volumes defined by an image

Wondering if an image has volumes? Just use ``docker inspect``:

    @@@ Sh
    $ # docker inspect training/datavol
    [{
      "config": {
        . . .
        "Volumes": {
            "/var/webapp": {}
        },
        . . .
    }]

<!SLIDE printonly>
# Checking volumes used by a container

To look which paths are actually volumes, and to what they are bound,
use ``docker inspect`` (again):

     @@@ Sh
     $ docker inspect <yourContainerID>
     [{
       "ID": "<yourContainerID>",
     . . .
       "Volumes": {
          "/var/webapp": "/var/lib/docker/vfs/dir/f4280c5b6207ed531efd4cc673ff620cef2a7980f747dbbcca001db61de04468"
       },
       "VolumesRW": {
          "/var/webapp": true
       },
     }]

* We can see that our volume is present on the file system of the Docker host.

<!SLIDE>
# Sharing a single file between the host and a container

The same ``-v`` flag can be used to share a single file.

One of the most interesting examples is to share the Docker control socket.

    @@@ Sh
    $ docker run -it -v /var/run/docker.sock:/var/run/docker.sock docker sh

Warning: when using such mounts, the container gains root-like access to the host.
It can potentially do bad things.

<!SLIDE>
# Volume plugins

You can install plugins to manage volumes backed by particular storage systems,
or providing extra features. For instance:

* [dvol](https://github.com/ClusterHQ/dvol) - allows to commit/branch/rollback volumes;
* [Flocker](https://clusterhq.com/flocker/introduction/), [REX-Ray](https://github.com/emccode/rexray) - create and manage volumes backed by an enterprise storage system (e.g. SAN or NAS), or by cloud block stores (e.g. EBS);
* [Blockbridge](http://www.blockbridge.com/), [Portworx](http://portworx.com/) - provide distributed block store for containers;
* and much more!

<!SLIDE>
# Section summary

We've learned how to:

* Create and manage volumes.
* Share volumes across containers.
* Share a host directory with one or many containers.

