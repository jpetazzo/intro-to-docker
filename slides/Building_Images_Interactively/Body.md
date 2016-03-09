<!SLIDE>
# Building Images Interactively

As we have seen, the images on the Docker Hub are sometimes very basic.

How do we want to construct our own images?

As an example, we will build an image that has `figlet`.

First, we will do it manually with `docker commit`.

Then, in an upcoming chapter, we will use a `Dockerfile` and `docker build`.

<!SLIDE>
# Building from a base

Our base will be the `ubuntu` image.

<!SLIDE>
# Create a new container and make some changes

Start an Ubuntu container:

    @@@ Sh
    $ docker run -it ubuntu
    root@<yourContainerId>:#/

Run the command `apt-get update` to refresh the list of packages available to install.

Then run the command `apt-get install figlet` to install the program we are interested in.

    @@@ Sh
    root@<yourContainerId>:#/ apt-get update && apt-get install figlet
    .... OUTPUT OF APT-GET COMMANDS ....

<!SLIDE>
# Inspect the changes

Type ``exit`` at the container prompt to leave the interactive session.

Now let's run `docker diff` to see the difference between the base image
and our container.

    @@@ Sh
    $ docker diff <yourContainerId>
    C /root
    A /root/.bash_history
    C /tmp
    C /usr
    C /usr/bin
    A /usr/bin/figlet
    ...

<!SLIDE>
# Docker tracks filesystem changes

As explained before:

* An image is read-only.
* When we make changes, they happen in a copy of the image.
* Docker can show the difference between the image, and its copy.
* For performance, Docker uses copy-on-write systems.
  <br/>(i.e. starting a container based on a big image
  doesn't incur a huge copy.)

<!SLIDE>
# Commit and run your image

The `docker commit` command will create a new layer with those changes,
and a new image using this new layer.

    @@@ Sh
    $ docker commit <yourContainerId>
    <newImageId>

The output of the ``docker commit`` command will be the ID for your newly created image.

We can run this image:

    @@@ Sh
    $ docker run -it <newImageId>
    root@fcfb62f0bfde:/# figlet hello
     _          _ _       
    | |__   ___| | | ___  
    | '_ \ / _ \ | |/ _ \ 
    | | | |  __/ | | (_) |
    |_| |_|\___|_|_|\___/ 


<!SLIDE>
# Tagging images

Referring to an image by its ID is not convenient. Let's tag it instead.

We can use the `tag` command:

    @@@ Sh
    $ docker tag <newImageId> figlet

But we can also specify the tag as an extra argument to `commit`:

    @@@ Sh
    $ docker commit <containerId> figlet

And then run it using its tag:

    @@@ Sh
    $ docker run -it figlet

<!SLIDE>
# What's next?

Manual process = bad.

Automated process = good.

In the next chapter, we will learn how to automate the build
process by writing a `Dockerfile`.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Create a new container and make some changes
To start, launch a terminal inside of a ``ubuntu`` container in interactive mode:

    @@@ Sh
    $ docker run -it ubuntu
    root@<yourContainerId>:#/

Run the command ``apt-get update`` to refresh the list of packages available to install, then run the command ``apt-get install -y cmatrix`` to install the program we are interested in.

    @@@ Sh
    root@<yourContainerId>:#/ apt-get update && apt-get install -y cmatrix
    .... OUTPUT OF APT-GET COMMANDS ....

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Exit out of the container and inspect the changes
Grab the container's ID and pass it to ``docker diff`` command as an argument:

    @@@ Sh
    $ docker ps -lq
    <yourContainerId>
    $ docker diff <yourContainerId>
    C /root
    A /root/.bash_history
    C /tmp
    C /usr
    C /usr/bin
    A /usr/bin/cmatrix


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Note that Docker has tracked the changes
Docker keeps track of every file which has changed (C), been added (A), or deleted (D) from the base image used to create the container.  For instance, in this container ``.bash_history`` has been created (since we executed commands at the bash prompt) and many files related to packaging have either been created or modified.

We can formalize these changes into an entirely new image using ``docker commit``.  The changes will appear as a new layer on top of the existing ones from the base image.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Commit your image
To create an image with a new layer reflecting what appeared in the diff, use ``docker commit <containerId>``.

    @@@ Sh
    $ docker commit <yourContainerId>
    <newImageId>

The output of the ``docker commit`` command will be the ID for your newly created image.  You can run:

    @@@ Sh
    $ docker run -it <newImageId> cmatrix

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Tagging images
To tag an image, use the ``docker tag`` command.

    @@@ Sh
    $ docker tag <newImageId> <dockerhubUsername>/cmatrix

Note that ``docker commit`` also accepts an additional argument if you want to include a tag with your ``docker commit`` command:

    @@@ Sh
    $ docker commit <containerId> <tagName>

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Using image and viewing history
As mentioned, you can use a tagged image like so:

    @@@ Sh
    $ docker run -it <dockerhubUsername>/cmatrix

If you are curious, you can view all of the layers composing an image (and their size, when they were created, etc.) with the ``docker history`` command:

    @@@ Sh
    $ docker history ubuntu
    IMAGE               CREATED             CREATED BY
    c3d5614fecc4        8 days ago          /bin/sh -c #(nop) CMD [bash]
    96e1c132acb3        8 days ago          /bin/sh -c apt-get update && apt-get dist-upg
    311ec46308da        8 days ago          /bin/sh -c sed -i 's/^#\s*\(deb.*universe\)$/
    1b2af7d5307a        8 days ago          /bin/sh -c rm -rf /var/lib/apt/lists/*
    c31865d83ea1        8 days ago          /bin/sh -c echo '#!/bin/sh' > /usr/sbin/polic
    8cbdf71a8e7f        8 days ago          /bin/sh -c #(nop) ADD file:c0f316fa0dcbdd4635
    511136ea3c5a        16 months ago
