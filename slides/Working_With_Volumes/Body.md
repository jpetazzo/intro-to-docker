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
        VOLUME /var/lib/postgresql

* On the command-line, with the ``-v`` flag for ``docker run``.

        @@@ Sh
        $ docker run -d -v /var/lib/postgresql \
          training/postgresql

In both cases, ``/var/lib/postgresql`` (inside the container) will be a volume.

<!SLIDE>
# Volumes bypass the copy-on-write system

Volumes act as passthroughs to the host filesystem.

* The I/O performance on a volume is exactly the same as I/O performance
  on the Docker host.
* When you ``docker commit``, the content of volumes is not brought into
  the resulting image.
* If a ``RUN`` instruction in a ``Dockerfile`` changes the content of a
  volume, those changes are not recorded neither.

<!SLIDE>
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

In the last exemple, it doesn't matter if container ``alpha`` is running or not.

Since Docker 1.9, we can see all existing volumes and manipulate them:

    @@@ Sh
    $ docker volume ls
    DRIVER              VOLUME NAME
    local               5b0b65e4316da67c2d471086640e6005ca2264f3...
    local               vol02
    local               vol04
    local               13b59c9936d78d109d094693446e174e5480d973...

Some of those volume names were explicit (vol02, vol04).

The others (the hex IDs) were generated automatically by Docker.


<!SLIDE>
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

<!SLIDE>
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

Let's create volumes directly (without data containers).

    @@@ Sh
    $ docker volume create --name=files
    files
    $ docker volume create --name=logs
    logs

Volumes are not anchored to a specific path.

<!SLIDE>
# Using our named volumes

* Volumes are used with the `-v` option.
* When a host path does not contain a /, it is considered to be a volume name.

Let's start the same containers as before:

    @@@ Sh
    $ docker run -d -v files:/var/www -v logs:/var/log webserver
    $ docker run -d -v files:/home/ftp ftpserver
    $ docker run -d -v logs:/var/log lumberjack

Again: volumes are not anchored to a specific path.

(This can be a good or a bad thing.)

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

<!SLIDE>
# Sharing a directory between the host and a container

The previous example would become something like this:

    @@@ Sh
    $ mkdir -p /mnt/files /mnt/logs
    $ docker run -d -v /mnt/files:/var/www -v /mnt/logs:/var/log webserver
    $ docker run -d -v /mnt/files:/home/ftp ftpserver
    $ docker run -d -v /mnt/logs:/var/log lumberjack

Note that the paths must be absolute.

Those volumes can also be shared with ``--volumes-from``.

<!SLIDE>
# Migrating data with `--volumes-from`

* Scenario: migrating from Redis 2.8 to Redis 3.0.
* We have a container (`myredis`) running Redis 2.8.
* Stop the `myredis` container.
* Start a new container, using the Redis 3.0 image, and the `--volumes-from` option.
* The new container will inherit the data of the old one.
* Newer containers can use `--volumes-from` too.

<!SLIDE>
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

<!SLIDE>
# Upgrading Redis

Stop the Redis container.

    @@@ Sh
    $ docker stop redis28

Start the new Redis container.

    @@@ Sh
    $ docker run -d --name redis30 --volume-from redis28 redis:3.0

<!SLIDE>
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

    (Unless you do some serious archeology in `/var/lib/docker`.)

* Since Engine 1.9, orphaned volumes can be listed with `docker volume ls` and mounted to containers with `-v`.

Ultimately, _you_ are the one responsible for logging,
monitoring, and backup of your volumes.

<!SLIDE>
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

<!SLIDE>
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
# Section summary

We've learned how to:

* Create and manage volumes.
* Share volumes across containers.
* Share a host directory with one or many containers.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Sharing volumes across containers.

1.  Create a container with a volume.

         @@@ Sh
         $ docker run -it --name alpha -v /var/log ubuntu bash
         root@<yourContainerID>:/# date >/var/log/now

2.  Start another container with the same volume.  Note the ``--volumes-from`` flag.

         @@@ Sh
         $ docker run --volumes-from alpha ubuntu cat /var/log/now
         Fri May 30 05:06:27 UTC 2014 

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: No-op data containers.
Try out making a data container with a no-op command such as `true`.

         @@@ Sh
         $ docker run --name wwwdata -v /var/lib/www busybox true
         $ docker run --name wwwlogs -v /var/log/www busybox true

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Sharing a directory between the host and a container

    @@@ Sh
    $ cd
    $ mkdir bindthis
    $ ls bindthis
    $ docker run -it -v $(pwd)/bindthis:/var/www/html/webapp ubuntu bash
    root@<yourContainerID>:/# touch /var/www/html/webapp/index.html 
    root@<yourContainerID>:/# exit
    $ ls boundmount_demo
    index.html 


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Chaining container volumes together.

1. Create an initial container.

         @@@ Sh
         $ docker run -it -v /var/appvolume --name appdata ubuntu bash
         root@<yourContainerID># 

2. Create some data in our data volume.

         @@@ Sh
         root@<yourContainerID># cd /var/appvolume
         root@<yourContainerID># echo "Hello" > data

3. Exit the container.

         @@@ Sh
         root@<yourContainerID># exit

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Chaining container volumes together.

1. Create a new container.

         @@@ Sh
         $ docker run -it --volumes-from appdata --name appserver1 ubuntu bash
         root@<yourContainerID>#

2. Let's view our data.

         @@@ Sh
         root@<yourContainerID># cat /var/appvolume/data
         Hello

3. Let's make a change to our data.

         @@@ Sh
         root@<yourContainerID># echo "Good bye" \
                                 >> /var/appvolume/data

4. Exit the container.

         @@@ Sh
         root@<yourContainerID># exit


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Chain containers with data volumes

1. Create a third container.

         @@@ Sh
         $ docker run -it --volumes-from appserver1 \
           --name appserver2 ubuntu bash
         root@179c063af97a#

2. Let's view our data.

         @@@ Sh
         root@179c063af97a# cat /var/appvolume/data
         Hello
         Good bye

3. Exit the container.

         @@@ Sh
         root@179c063af97a# exit

4. Tidy up your containers.

         @@@ Sh
         $ docker rm -v appdata appserver1 appserver2

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Sharing a single file between the host and a container


    @@@ Sh
    $ echo 4815162342 > /tmp/numbers
    $ docker run -it -v /tmp/numbers:/numbers ubuntu bash
    root@274514a6e2eb:/# cat /numbers 
    4815162342


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Sharing a socket and docker binary with a container


    @@@ Sh
    $ docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/docker ubuntu ./docker
    Usage: docker [OPTIONS] COMMAND [arg...]

     -H=[unix:///var/run/docker.sock]: tcp://host:port to bind/connect to or unix://path/to/socket to use

    A self-sufficient runtime for linux containers.

    ....

Be careful: if a container can access `/var/run/docker.sock`, it will
be able to do *anything it wants* on the host!

