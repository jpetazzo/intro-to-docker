<!SLIDE>
# What is an image?

* An image is a collection of files + some meta data.
  <br/>(Technically: those files form the root filesystem of a container.)
* Images are made of *layers*, conceptually stacked on top of each other.
* Each layer can add, change, and remove files.
* Images can share layers to optimize disk usage, transfer times, and memory use.

* Example:
  * CentOS
  * JRE
  * Tomcat
  * Dependencies
  * Application JAR
  * Configuration

<!SLIDE>
# Differences between containers and images

* An image is a read-only filesystem.
* A container is an encapsulated set of processes running in a
  read-write copy of that filesystem.
* To optimize container boot time, *copy-on-write* is used 
  instead of regular copy.
* `docker run` starts a container from a given image.

Let's give a couple of metaphors to illustrate those concepts.

<!SLIDE>
# Image as stencils

Images are like templates or stencils that you can create containers from.

![stencil](stenciling-wall.jpg)

<!SLIDE>
# Object-oriented programming

* Images are conceptually similar to *classes*.
* Layers are conceptually similar to *inheritance*.
* Containers are conceptually similar to *instances*.

<!SLIDE>
# Wait a minute...

If an image is read-only, how do we change it?

* We don't.
* We create a new container from that image.
* Then we make changes to that container.
* When we are satisfied with those changes, we transform them into a new layer.
* A new image is created by stacking the new layer on top of the old image.

<!SLIDE>
# A chicken-and-egg problem

* The only way to create an image is by "freezing" a container.
* The only way to create a container is by instanciating an image.
* Help!

<!SLIDE>
# Creating the first images

There is a special empty image called `scratch`. 

* It allows to *build from scratch*.

The `docker import` command loads a tarball into Docker.

* The imported tarball becomes a standalone image.
* That new image has a single layer.

Note: you will probably never have to do this yourself.

<!SLIDE>
# Creating other images

`docker commit`

* Saves all the changes made to a container into a new layer.
* Creates a new image (effectively a copy of the container).

`docker build`

* Performs a repeatable build sequence.
* This is the preferred method!

We will explain both methods in a moment.

<!SLIDE>
# Images namespaces

There are three namespaces:

* Official images

    e.g. `ubuntu`, `busybox` ...

* User (and organizations) images

    e.g. `jpetazzo/clock`

* Self-hosted images

    e.g. `registry.example.com:5000/my-private/image`

Let's explain each of them.

<!SLIDE>
# Root namespace

The root namespace is for official images. They are put there by Docker Inc.,
but they are generally authored and maintained by third parties.

Those images include:

* Small, "swiss-army-knife" images like busybox.
* Distro images to be used as bases for your builds, like ubuntu, fedora...
* Ready-to-use components and services, like redis, postgresql...


<!SLIDE>
# User namespace

The user namespace holds images for Docker Hub users and organizations.

For example:

    @@@ Sh
    jpetazzo/clock

The Docker Hub user is:

    @@@ Sh
    jpetazzo

The image name is:

    @@@ Sh
    clock

<!SLIDE>
# Self-Hosted namespace

This namespace holds images which are not hosted on Docker Hub, but on third
party registries.

They contain the hostname (or IP address), and optionally the port, of the
registry server.

For example:

    @@@ Sh
    localhost:5000/wordpress

* `localhost:5000` is the host and port of the registry
* `wordpress` is the name of the image

<!SLIDE>
# How do you store and manage images?

Images can be stored:

* On your Docker host.
* In a Docker registry.

You can use the Docker client to download (pull) or upload (push) images.

To be more accurate: you can use the Docker client to tell a Docker server
to push and pull images to and from a registry.

<!SLIDE>
# Showing current images

Let's look at what images are on our host now.

    @@@ Sh
    $ docker images
    REPOSITORY       TAG       IMAGE ID       CREATED         SIZE
    fedora           latest    ddd5c9c1d0f2   3 days ago      204.7 MB
    centos           latest    d0e7f81ca65c   3 days ago      196.6 MB
    ubuntu           latest    07c86167cdc4   4 days ago      188 MB
    redis            latest    4f5f397d4b7c   5 days ago      177.6 MB
    postgres         latest    afe2b5e1859b   5 days ago      264.5 MB
    alpine           latest    70c557e50ed6   5 days ago      4.798 MB
    debian           latest    f50f9524513f   6 days ago      125.1 MB
    busybox          latest    3240943c9ea3   2 weeks ago     1.114 MB
    training/namer   latest    902673acc741   9 months ago    289.3 MB
    jpetazzo/clock   latest    12068b93616f   12 months ago   2.433 MB


<!SLIDE>
# Searching for images

We cannot list *all* images on a remote registry, but
we can search for a specific keyword:

    @@@ Sh
    $ docker search zookeeper
    NAME                  DESCRIPTION                 STARS  OFFICIAL  AUTOMATED
    jplock/zookeeper      Builds a docker image ...   103              [OK]
    mesoscloud/zookeeper  ZooKeeper                   42               [OK]
    springxd/zookeeper    A Docker image that ca...   5                [OK]
    elevy/zookeeper       ZooKeeper configured t...   3                [OK]


* "Stars" indicate the popularity of the image.
* "Official" images are those in the root namespace.
* "Automated" images are built automatically by the Docker Hub.
  <br/>(This means that their build recipe is always available.)

<!SLIDE>
# Downloading images

There are two ways to download images.

* Explicitly, with `docker pull`.
* Implicitly, when executing `docker run` and the image is not found locally.

<!SLIDE>
# Pulling an image

    @@@ Sh
    $ docker pull debian:jessie
    Pulling repository debian
    b164861940b8: Download complete 
    b164861940b8: Pulling image (jessie) from debian 
    d1881793a057: Download complete 

* As seen previously, images are made up of layers.
* Docker has downloaded all the necessary layers.
* In this example, `:jessie` indicates which exact version of Debian
  we would like. It is a *version tag*.

<!SLIDE>
# Image and tags

* Images can have tags.
* Tags define image versions or variants.
* `docker pull ubuntu` will refer to `ubuntu:latest`.
* The `:latest` tag is generally updated often.

<!SLIDE>
# When to (not) use tags

Don't specify tags:

* When doing rapid testing and prototyping.
* When experimenting.
* When you want the latest version.

Do specify tags:

* When recording a procedure into a script.
* When going to production.
* To ensure that the same version will be used everywhere.
* To ensure repeatability later.

<!SLIDE>
# Section summary

We've learned how to:

* Understand images and layers.
* Understand Docker image namespacing.
* Search and download images.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Find an image

1. Run the ``docker search`` command.

        @@@ Sh
        $ docker search training

2. You should see something like:

        @@@ Sh
        NAME                                    DESCRIPTION   STARS     OFFICIAL   AUTOMATED
        training/jenkins                                      0                    [OK]
        training/webapp                                       0                    [OK]
        training/ls                                           0                    [OK]
        training/namer                                        0                    [OK]
        training/postgres                                     0                    [OK]
        training/notes                                        0                    [OK]
        training/docker-fundamentals-image                    0                    [OK]
        training/showoff                                      0                    
        . . .

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Retrieve a user image

1. Pull down the ``training/docker-fundamentals-image`` image using the 
   ``docker pull`` command.

        @@@ Sh
        $ docker pull training/docker-fundamentals-image
        Pulling repository training/docker-fundamentals-image
        8144a5b2bc0c: Pulling dependent layers
        511136ea3c5a: Download complete
        8abc22fbb042: Download complete

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Show currently installed images

1. View the currently installed images using the ``docker images``
   command.

        @@@ Sh
        $ docker images
        REPOSITORY                         TAG     IMAGE ID     CREATED     VIRTUAL SIZE
        training/docker-fundamentals-image latest  8144a5b2bc0c 5 days ago  835 MB
        ubuntu                             13.10   9f676bd305a4 7 weeks ago 178 MB
        ubuntu                             saucy   9f676bd305a4 7 weeks ago 178 MB
        ubuntu                             raring  eb601b8965b8 7 weeks ago 166.5 MB
        ubuntu                             13.04   eb601b8965b8 7 weeks ago 166.5 MB
        ubuntu                             12.10   5ac751e8d623 7 weeks ago 161 MB
        ubuntu                             quantal 5ac751e8d623 7 weeks ago 161 MB
        ubuntu                             10.04   9cc9ea5ea540 7 weeks ago 180.8 MB
        ubuntu                             lucid   9cc9ea5ea540 7 weeks ago 180.8 MB
        ubuntu                             12.04   9cd978db300e 7 weeks ago 204.4 MB
        ubuntu                             latest  9cd978db300e 7 weeks ago 204.4 MB
        ubuntu                             precise 9cd978db300e 7 weeks ago 204.4 MB

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Retrieve a tagged image

1. Pull down a tagged image using the ``docker pull`` command.

        @@@ Sh
        $ docker pull debian:jessie
        Pulling repository debian
        58394af37342: Download complete
        511136ea3c5a: Download complete
        8abc22fbb042: Download complete
