<!SLIDE>
# From `curl` to `wget`

In this chapter, the package that we will install will be `wget`.

Why are we using `wget` instead of `curl`?

The reasons are purely pedagogic:

* You will be able to do this section using a different distro (if you
  are so inclined). While `curl` is pre-installed on `centos` and
  `fedora`, `wget` is not.
* To achieve the nice, clean output of `curl`, we need to pass extra
  arguments to `wget`. While this would be annoying in a real life
  situation, it will be an excellent opportunity to show how
  to pass command-line options in Dockerfiles.

<!SLIDE>
# `Dockerfile` overview

* A `Dockerfile` is a build recipe for a Docker image.
* It contains a series of instructions telling Docker how an image is constructed.
* The `docker build` command builds an image from a ``Dockerfile``.

<!SLIDE>
# Writing our first `Dockerfile`

Our Dockerfile must be in a **new, empty directory**.

1. Create a directory to hold our ``Dockerfile``.

        @@@ Sh
        $ mkdir myimage

2. Create a ``Dockerfile`` inside this directory.

        @@@ Sh
        $ cd myimage
        $ vim Dockerfile

Of course, you can use any other editor of your choice.

<!SLIDE>
# Type this into our Dockerfile...

    @@@ docker
    FROM ubuntu
    RUN apt-get update
    RUN apt-get install -y wget

* `FROM` indicates the base image for our build.
* Each `RUN` line will be executed by Docker during the build.
* Our `RUN` commands **must be non-interactive.**
  <br/>(No input can be provided to Docker during the build.)

<!SLIDE>
# Build it!

Save our file, then execute:

    @@@ Sh
    $ docker build -t myimage .

* `-t` indicates the tag to apply to the image.
* `.` indicates the location of the *build context*.
  <br/>(We will talk more about the build context later;
  but to keep things simple: this is the directory where
  our Dockerfile is located.)

<!SLIDE>
# What happens when we build the image?

The output of `docker build` looks like this:

    @@@ Sh
    $ docker build -t myimage .
    Sending build context to Docker daemon 2.048 kB
    Sending build context to Docker daemon 
    Step 0 : FROM ubuntu
     ---> e54ca5efa2e9
    Step 1 : RUN apt-get update
     ---> Running in 840cb3533193
     ---> 7257c37726a1
    Removing intermediate container 840cb3533193
    Step 2 : RUN apt-get install -y wget
     ---> Running in 2b44df762a2f
     ---> f9e8f1642759
    Removing intermediate container 2b44df762a2f
    Successfully built f9e8f1642759

* The output of the `RUN` commands has been omitted.
* Let's explain what this output means.

<!SLIDE>
# Sending the build context to Docker

    @@@ Sh
    Sending build context to Docker daemon 2.048 kB

* The build context is the `.` directory given to `docker build`.
* It is sent (as an archive) by the Docker client to the Docker daemon.
* This allows to use a remote machine to build using local files.
* Be careful (or patient) if that directory is big and your link is slow.

<!SLIDE>
# Executing each step

    @@@ Sh
    Step 1 : RUN apt-get update
     ---> Running in 840cb3533193
    (...output of the RUN command...)
     ---> 7257c37726a1
    Removing intermediate container 840cb3533193

* A container (`840cb3533193`) is created from the base image.
* The `RUN` command is executed in this container.
* The container is committed into an image (`7257c37726a1`).
* The build container (`840cb3533193`) is removed.
* The output of this step will be the base image for the next one.

<!SLIDE>
# Running the image

The resulting image is not different from the one produced manually.

    @@@ Sh
    $ docker run -ti myimage bash
    root@91f3c974c9a1:/# wget
    wget: missing URL

* Sweet is the taste of success!

<!SLIDE>
# Using image and viewing history

The `history` command lists all the layers composing an image.

For each layer, it shows its creation time, size, and creation command.

When an image was built with a Dockerfile, each layer corresponds to
a line of the Dockerfile.

    @@@ Sh
    $ docker history myimage
    IMAGE         CREATED            CREATED BY                     SIZE
    f9e8f1642759  About an hour ago  /bin/sh -c apt-get install -y  6.062 MB
    7257c37726a1  About an hour ago  /bin/sh -c apt-get update      8.549 MB
    e54ca5efa2e9  8 months ago       /bin/sh -c apt-get update &&   8 B
    6c37f792ddac  8 months ago       /bin/sh -c apt-get update &&   83.43 MB
    83ff768040a0  8 months ago       /bin/sh -c sed -i  s/^#\s*\(d  1.903 kB
    2f4b4d6a4a06  8 months ago       /bin/sh -c echo  #!/bin/sh  >  194.5 kB
    d7ac5e4f1812  8 months ago       /bin/sh -c #(nop) ADD file:ad  192.5 MB
    511136ea3c5a  20 months ago                                     0 B

