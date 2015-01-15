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

<!SLIDE>
# Data containers

A *data container* is a container created for the sole purpose of referencing
one (or many) volumes.

It is typically created with a no-op command:

    @@@ Sh
    $ docker run --name wwwdata -v /var/lib/www busybox true
    $ docker run --name wwwlogs -v /var/log/www busybox true

* We created two data containers.
* They are using the ``busybox`` image, a tiny image.
* We used the command ``true``, possibly the simplest command in the world!
* We named each container to reference them easily later.

Try it out!

<!SLIDE>
# Using data containers

Data containers are used by other containers thanks to ``--volumes-from``.

Consider the following (fictitious) example, using the previously created volumes:

    @@@ Sh
    $ docker run -d --volumes-from wwwdata --volumes-from wwwlogs webserver
    $ docker run -d --volumes-from wwwdata ftpserver
    $ docker run -d --volumes-from wwwlogs pipestash

* The first container runs a webserver, serving content from ``/var/lib/www``
  and logging to ``/var/log/www``.
* The second container runs a FTP server, allowing to upload content to the
  same ``/var/lib/www`` path.
* The third container collects the logs, and sends them to logstash, a log
  storage and analysis system.

<!SLIDE>
# Managing volumes yourself (instead of letting Docker do it)

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

    @@@ Sh
    $ cd
    $ mkdir bindthis
    $ ls bindthis
    $ docker run -it -v $(pwd)/bindthis:/var/www/html/webapp ubuntu bash
    root@<yourContainerID>:/# touch /var/www/html/webapp/index.html 
    root@<yourContainerID>:/# exit
    $ ls bindthis
    index.html 

This will mount the ``bindthis`` directory into the container at
``/var/www/html/webapp``.

Note that the paths must be absolute.

It defaults to mounting read-write but we can also mount read-only.

    @@@ Sh
    $ docker run -it -v $(pwd)/bindthis:/var/www/html/webapp:ro ubuntu bash

Those volumes can also be shared with ``--volumes-from``.

<!SLIDE>
# Chaining container volumes together

Let's see how to put both pieces together.

1. Create an initial container.

         @@@ Sh
         $ docker run -it -v /var/appvolume \
           --name appdata ubuntu bash
         root@<yourContainerID># 

2. Create some data in our data volume.

         @@@ Sh
         root@<yourContainerID># cd /var/appvolume
         root@<yourContainerID># echo "Hello" > data

3. Exit the container.

         @@@ Sh
         root@<yourContainerID># exit

<!SLIDE>
# Use a data volume from our container.

1. Create a new container.

         @@@ Sh
         $ docker run -it --volumes-from appdata \
           --name appserver1 ubuntu bash
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


<!SLIDE>
# Chain containers with data volumes


1. Create a third container.

         @@@ Sh
         docker run -it --volumes-from appserver1 --name appserver2 ubuntu bash
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

<!SLIDE>
# What happens when you remove containers with volumes?

* As long as a volume is referenced by at least one container,
  you will be able to access it.
* When you remove the last container referencing a volume,
  that volume will be orphaned.
* Orphaned volumes are not deleted (as of Docker 1.2).
* The data is not lost, but you will not be able to access it.

    (Unless you do some serious archeology in `/var/lib/docker`.)

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

    @@@ Sh
    $ echo 4815162342 > /tmp/numbers
    $ docker run -it -v /tmp/numbers:/numbers ubuntu bash
    root@<yourContainerId>:/# cat /numbers 
    4815162342

* All modifications done to ``/numbers`` in the container will also change
  ``/tmp/numbers`` on the host!

It can also be used to share a *socket*.

    @@@ Sh
    $ docker run -it -v /var/run/docker.sock:/docker.sock ubuntu bash

* This pattern is frequently used to give access to the Docker socket to a
  given container.

Warning: when using such mounts, the container gains root-like access to the host.
It can potentially do bad things.

<!SLIDE>
# Section summary

We've learned how to:

* Create containers holding volumes.
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

