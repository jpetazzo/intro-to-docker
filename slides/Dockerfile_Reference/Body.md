<!SLIDE>
# ``Dockerfile`` usage summary

* ``Dockerfile`` instructions are executed in order.
* Each instruction creates a new layer in the image.
* Instructions are cached. If no changes are detected then the
  instruction is skipped and the cached layer used.
* The ``FROM`` instruction MUST be the first non-comment instruction.
* Lines starting with ``#`` are treated as comments.
* You can only have one ``CMD`` and one ``ENTRYPOINT`` instruction in a ``Dockerfile``.

<!SLIDE>
# The ``FROM`` instruction

* Specifies the source image to build this image.
* Must be the first instruction in the ``Dockerfile``, except for comments.

<!SLIDE>
# The ``FROM`` instruction
Can specify a base image:

    @@@ docker
    FROM ubuntu

An image tagged with a specific version:

    @@@ docker
    FROM ubuntu:12.04

A user image:

    @@@ docker
    FROM training/sinatra

Or self-hosted image:

    @@@ docker
    FROM localhost:5000/funtoo

<!SLIDE>
# More about ``FROM``

* The ``FROM`` instruction can be specified more than once to build
  multiple images.

        @@@ docker
        FROM ubuntu:14.04
        . . .
        FROM fedora:20
        . . .

    Each ``FROM`` instruction marks the beginning of the build of a new image.

    The ``-t`` command-line parameter will only apply to the last image.

* If the build fails, existing tags are left unchanged.

* An optional version tag can be added after the name of the image.

    E.g.: ``ubuntu:14.04``.

<!SLIDE>
# A use case for multiple ``FROM`` lines

* Integrate CI and unit tests in the build system

        @@@ docker
        FROM <baseimage>
        RUN <install dependencies>
        COPY <code>
        RUN <build code>
        RUN <install test dependencies>
        COPY <test data sets and fixtures>
        RUN <unit tests>
        FROM <baseimage>
        RUN <install dependencies>
        COPY <vcode>
        RUN <build code>
        CMD, EXPOSE ...

* The build fails as soon as an instructions fails
* If `RUN <unit tests>` fails, the build doesn't produce an image
* If it succeeds, it produces a clean image (without test libraries and data)

<!SLIDE>
# The ``MAINTAINER`` instruction

The ``MAINTAINER`` instruction tells you who wrote the ``Dockerfile``.

    @@@ docker
    MAINTAINER Docker Education Team <education@docker.com>

It's optional but recommended.

<!SLIDE>
# The ``RUN`` instruction

The ``RUN`` instruction can be specified in two ways.

With shell wrapping, which runs the specified command inside a shell,
with ``/bin/sh -c``:

    @@@ docker
    RUN apt-get update

Or using the ``exec`` method, which avoids shell string expansion, and
allows execution in images that don't have ``/bin/sh``:

    @@@ docker
    RUN [ "apt-get", "update" ]

<!SLIDE>
# More about the ``RUN`` instruction

``RUN`` will do the following:

* Execute a command.
* Record changes made to the filesystem.
* Work great to install libraries, packages, and various files.

``RUN`` will NOT do the following:

* Record state of *processes*.
* Automatically start daemons.

If you want to start something automatically when the container runs,
you should use ``CMD`` and/or ``ENTRYPOINT``.

<!SLIDE>
# Collapsing layers

It is possible to execute multiple commands in a single step:

    @@@ docker
    RUN apt-get update && apt-get install -y wget && apt-get clean

It is also possible to break a command on multiple lines:

It is possible to execute multiple commands in a single step:

    @@@ docker
    RUN apt-get update \
     && apt-get install -y wget \
     && apt-get clean

<!SLIDE>
# The ``EXPOSE`` instruction

The ``EXPOSE`` instruction tells Docker what ports are to be published
in this image.

    @@@ docker
    EXPOSE 8080
    EXPOSE 80 443
    EXPOSE 53/tcp 53/udp

* All ports are private by default.
* The ``Dockerfile`` doesn't control if a port is publicly available.
* When you ``docker run -p <port> ...``, that port becomes public.

    (Even if it was not declared with ``EXPOSE``.)

* When you ``docker run -P ...`` (without port number), all ports
  declared with ``EXPOSE`` become public.

A *public port* is reachable from other containers and from outside the host.

A *private port* is not reachable from outside.

<!SLIDE>
# The ``COPY`` instruction

The ``COPY`` instruction adds files and content from your host into the
image.

    @@@ docker
    COPY . /src

This will add the contents of the *build context* (the directory
passed as an argument to `docker build`) to the directory `/src`
in the container.

Note: you can only reference files and directories *inside* the
build context. Absolute paths are taken as being anchored to
the build context, so the two following lines are equivalent:

    @@@ docker
    COPY . /src
    COPY / /src

Attempts to use `..` to get out of the build context will be
detected and blocked with Docker, and the build will fail.

Otherwise, a ``Dockerfile`` could succeed on host A, but fail on host B.

<!SLIDE>
# `ADD`

`ADD` works almost like `COPY`, but has a few extra features.

`ADD` can get remote files:

    @@@ docker
    ADD http://www.example.com/webapp.jar /opt/

This would download the ``webapp.jar`` file and place it in the ``/opt``
directory.

`ADD` will automatically unpack zip files and tar archives:

    @@@ docker
    ADD ./assets.zip /var/www/htdocs/assets/

This would unpack `assets.zip` into `/var/www/htdocs/assets`.

*However,* `ADD` will not automatically unpack remote archives.

<!SLIDE>
# `ADD`, `COPY`, and the build cache

* For most Dockerfiles instructions, Docker only checks
  if the line in the Dockerfile has changed.
* For `ADD` and `COPY`, Docker also checks if the files
  to be added to the container have been changed.
* `ADD` always need to download the remote file before
  it can check if it has been changed. (It cannot use,
  e.g., ETags or If-Modified-Since headers.)

<!SLIDE>
# `VOLUME`

The `VOLUME` instruction tells Docker that a specific directory
should be a *volume*.

    @@@ docker
    VOLUME /var/lib/mysql

Filesystem access in volumes bypasses the copy-on-write layer,
offering native performance to I/O done in those directories.

Volumes can be attached to multiple containers, allowing to
"port" data over from a container to another, e.g. to
upgrade a database to a newer version.

<!SLIDE>
# The ``WORKDIR`` instruction

The ``WORKDIR`` instruction sets the working directory for subsequent
instructions.

It also affects ``CMD`` and ``ENTRYPOINT``, since it sets the working
directory used when starting the container.
   
    @@@ docker
    WORKDIR /src

You can specify ``WORKDIR`` again to change the working directory for
further operations.

<!SLIDE>
# The ``ENV`` instruction

The ``ENV`` instruction specifies environment variables that should be
set in any container launched from the image.

    @@@ docker
    ENV WEBAPP_PORT 8080

This will result in an environment variable being created in any
containers created from this image of

    @@@ Sh
    WEBAPP_PORT=8080

You can also specify environment variables when you use ``docker run``.

    @@@ Sh
    $ docker run -e WEBAPP_PORT=8000 -e WEBAPP_HOST=www.example.com ...

<!SLIDE>
# The ``USER`` instruction

The ``USER`` instruction sets the user name or UID to use when running
the image.

It can be used multiple times to change back to root or to another user.

<!SLIDE>
# The ``CMD`` instruction

The ``CMD`` instruction is a default command run when a container is
launched from the image.

    @@@ docker
    CMD [ "nginx", "-g", "daemon off;" ]

Means we don't need to specify ``nginx -g "daemon off;"`` when running the
container.

Instead of:

    @@@ Sh
    $ docker run <dockerhubUsername>/web_image nginx -g "daemon off;"

We can just do:

    @@@ Sh
    $ docker run <dockerhubUsername>/web_image

<!SLIDE>
# More about the ``CMD`` instruction

Just like ``RUN``, the ``CMD`` instruction comes in two forms.
The first executes in a shell:

    @@@ docker
    CMD nginx -g "daemon off;"

The second executes directly, without shell processing:

    @@@ docker
    CMD [ "nginx", "-g", "daemon off;" ]

<!SLIDE>
# Overriding the ``CMD`` instruction

The ``CMD`` can be overridden when you run a container.

    @@@ Sh
    $ docker run -it <dockerhubUsername>/web_image bash

Will run ``bash`` instead of ``nginx -g "daemon off;"``.

<!SLIDE>
# The ``ENTRYPOINT`` instruction

The ``ENTRYPOINT`` instruction is like the ``CMD`` instruction,
but arguments given on the command line are *appended* to the
entry point.

Note: you have to use the "exec" syntax (``[ "..." ]``).

    @@@ docker
    ENTRYPOINT [ "/bin/ls" ]

If we were to run:

    @@@ Sh
    $ docker run training/ls -l

Instead of trying to run ``-l``, the container will run ``/bin/ls -l``.

<!SLIDE>
# Overriding the ``ENTRYPOINT`` instruction

The entry point can be overriden as well.

    @@@ Sh
    $ docker run -it training/ls
    bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
    boot  etc  lib   media  opt  root  sbin  sys  usr
    $ docker run -it --entrypoint bash training/ls
    root@d902fb7b1fc7:/#

<!SLIDE>
# How ``CMD`` and ``ENTRYPOINT`` interact

The ``CMD`` and ``ENTRYPOINT`` instructions work best when used
together.

    @@@ docker
    ENTRYPOINT [ "nginx" ]
    CMD [ "-g", "daemon off;" ]

The ``ENTRYPOINT`` specifies the command to be run and the ``CMD``
specifies its options. On the command line we can then potentially
override the options when needed.

    @@@ Sh
    $ docker run -d <dockerhubUsername>/web_image -t

This will override the options ``CMD`` provided with new flags.

<!SLIDE>
# The ``ONBUILD`` instruction

The ``ONBUILD`` instruction is a trigger. It sets instructions that will
be executed when another image is built from the image being build.

This is useful for building images which will be used as a base
to build other images.

    @@@ docker
    ONBUILD COPY . /src

* You can't chain ``ONBUILD`` instructions with ``ONBUILD``.
* ``ONBUILD`` can't be used to trigger ``FROM`` and ``MAINTAINER``
  instructions.

<!SLIDE>
# Building an efficient ``Dockerfile`` 

* Each line in a ``Dockerfile`` creates a new layer.
* Build your ``Dockerfile`` to take advantage of Docker's caching system.
* Combine multiple similar commands into one by using ``&&`` to continue commands and ``\\`` to wrap lines.
* ``COPY`` dependency lists (``package.json``,``requirements.txt``, etc.) by themselves to avoid reinstalling unchanged dependencies every time.

<!SLIDE>
# Example "bad" ``Dockerfile``

The dependencies are reinstalled every time, because the build system does not know if ``requirements.txt`` has been updated.

        @@@ Sh
        FROM ubuntu:14.04
        MAINTAINER Docker Education Team <education@docker.com>
        RUN apt-get update
        RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
            python-all python-pip 
        COPY . /src/
        WORKDIR /src
        RUN pip install -qr requirements.txt
        EXPOSE 5000
        CMD ["python", "app.py"]

<!SLIDE>
# Fixed ``Dockerfile``

Adding the dependencies as a separate step means that Docker can cache more efficiently and only install them when ``requirements.txt`` changes.

        @@@ sh
        FROM ubuntu:14.04
        MAINTAINER Docker Education Team <education@docker.com>
        RUN apt-get update
        RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
            python-all python-pip 
        COPY ./requirements.txt /tmp/requirements.txt
        RUN pip install -qr /tmp/requirements.txt
        COPY . /src/
        WORKDIR /src
        EXPOSE 5000
        CMD ["python", "app.py"]


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Building your own ``Dockerfile``

1. Create a directory to hold our ``Dockerfile``.

        @@@ Sh
        $ mkdir web_image

2. Create a ``Dockerfile`` inside this directory.

        @@@ Sh
        $ cd web_image
        $ touch Dockerfile

3. Edit our ``Dockerfile``.

        @@@ Sh
        $ vim Dockerfile

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Adding ``FROM`` and ``MAINTAINER`` instructions

1. Let's start with a ``FROM`` instruction.

        @@@ docker
        FROM ubuntu:14.04

2. Add a ``MAINTAINER`` instruction.

         @@@ docker
         MAINTAINER Your Name <your@email.com>

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Installing some packages to support our application

1. Update, install some required packages, and add a simple site to be served, using the ``RUN`` instruction.

         @@@ docker
         RUN apt-get update
         RUN apt-get install -y nginx
         RUN echo 'Hi, I am in your container' \
             >/usr/share/nginx/html/index.html

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Install our web application.

1. Set the `CMD` instruction using the array notation.  This will be run when
the container is started.

        @@@ docker
        CMD ["nginx", "-g", "daemon off;"]

2. Lastly, use `EXPOSE` to expose port 80.

        @@@ docker
        EXPOSE 80

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Building our web application image.

1. Use ``docker build`` to build our image.

        @@@ Sh
        $ docker build -t <dockerhubUsername>/web_image .

2. Review the build image with ``docker image``.

        @@@ Sh
        $ docker image <dockerhubUsername>/web_image
        REPOSITORY                    TAG     IMAGE ID      CREATED        VIRTUAL SIZE
        <dockerhubUsername>/web_image latest  e2a9fac29d86  12 seconds ago 246.8 MB

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Overriding the ``CMD`` instruction

1. Specify a command to run instead of the ``CMD`` defined when doing ``docker
   run``:

        @@@Sh
        docker run -it <dockerhubUsername>/web_image bash

   This overrides the default ``CMD``.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Overriding the ``ENTRYPOINT`` instruction

1.  Specify a command to run instead of the ``ENTRYPOINT`` defined in the
    Dockerfile.

    Without ``--entrypoint``:

        @@@ Sh
        $ docker run -it training/ls
        bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
        boot  etc  lib   media  opt  root  sbin  sys  usr

    With ``--entrypoint``:

        @@@ Sh
        $ docker run -it --entrypoint bash training/ls
        root@d902fb7b1fc7:/#

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Running a container from our image

1. Now let's run a container from our new image using the ``docker run``
   command.  The ``-P`` automatically maps all ports exposed in an image to 
   random ports on the host.

        @@@ Sh
        $ docker run -d -P <dockerhubUsername>/web_image


2. Now checkout our running container using the ``docker ps`` command. The 
   ``-l`` flag returns the last container created.

        @@@ Sh
        $ docker ps -l

3. You should see something like:

         @@@ Sh
         CONTAINER ID IMAGE                                COMMAND              CREATED       STATUS       PORTS                 NAMES
         25af0d10060f <dockerhubUsername>/web_image:latest nginx -g daemon off; 2 minutes ago Up 2 minutes 0.0.0.0:49162->80/tcp tender_newton

   Make a note of the port number port ``5000`` is being redirected to.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Using our web application

1. Open a browser and browse to the redirected port on the Docker host.

         @@@ Sh
         http://<yourHostIP>:redirectedport

2. You should see something like.

![webapp](webapp.png)
