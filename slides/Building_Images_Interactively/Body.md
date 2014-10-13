<!SLIDE>
# Building Images Interactively

* We've learned a bit about Docker images and containers.
* We could use base images that Docker Hub or its users provide, but what if we want to construct our own custom images?
* This can be done manually using ``docker commit`` or automatically using a ``Dockerfile``.  We will learn the manual way first and then look at ``Dockerfile``s in the next section.

<!SLIDE>
# Building from a base

We will use the ``ubuntu`` image that we pulled from Docker Hub as a basis for our customized image.

We are going to install the program ``cmatrix`` and commit the change as an image so we can create conatiners from that image again and again.

<!SLIDE>
# Create a new container and make some changes

To start, launch a terminal inside of a ``ubuntu`` container in interactive mode:

    @@@ Sh
    $ docker run -it ubuntu bash
    root@<yourContainerId>:#/

Run the command ``apt-get update`` to refresh the list of packages available to install, then run the command ``apt-get install -y cmatrix`` to install the program we are interested in.

    @@@ Sh
    root@<yourContainerId>:#/ apt-get update && apt-get install -y cmatrix
    .... OUTPUT OF APT-GET COMMANDS ....

<!SLIDE>
# Exit out of the container and inspect the changes

Type ``exit`` at the container prompt to leave the interactive session, then examine the details of the container you were just running with ``docker ps -l``.  Grab the container's ID and pass it to ``docker diff`` command as an argument:

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
    ...

<!SLIDE>
# Note that Docker has tracked the changes

Docker keeps track of every file which has changed (C), been added (A), or deleted (D) from the base image used to create the container.  For instance, in this container ``.bash_history`` has been created (since we executed commands at the bash prompt) and many files related to packaging have either been created or modified.

We can formalize these changes into an entirely new image using ``docker commit``.  The changes will appear as a new layer on top of the existing ones from the base image.

<!SLIDE>
# Commit your image

To create an image with a new layer reflecting what appeared in the diff, use ``docker commit <containerId>``.

    @@@ Sh
    $ docker commit <yourContainerId>
    <newImageId>

The output of the ``docker commit`` command will be the ID for your newly created image.  You can run:

    @@@ Sh
    $ docker run -it <newImageId> cmatrix

<!SLIDE>
# Tagging images

Any image can be _tagged_ for easy reference (or to prepare it to be pushed to a registry such as Docker Hub).  To tag an image, use the ``docker tag`` command.

    @@@ Sh
    $ docker tag <newImageId> <dockerhubUsername>/cmatrix

Note that ``docker commit`` also accepts an additional argument if you want to include a tag with your ``docker commit`` command:

    @@@ Sh
    $ docker commit <containerId> <tagName>

<!SLIDE>
# Using image and viewing history

As mentioned, you can use a tagged image like so:

    @@@ Sh
    $ docker run -it <dockerhubUsername>/cmatrix

If you are curious, you can view all of the layers composing an image (and their size, when they were created, etc.) with the ``docker history`` command:

    @@@ Sh
    $ docker history ubuntu
    IMAGE               CREATED             CREATED BY
    c3d5614fecc4        8 days ago          /bin/sh -c #(nop) CMD [/bin/bash]
    96e1c132acb3        8 days ago          /bin/sh -c apt-get update && apt-get dist-upg
    311ec46308da        8 days ago          /bin/sh -c sed -i 's/^#\s*\(deb.*universe\)$/
    1b2af7d5307a        8 days ago          /bin/sh -c rm -rf /var/lib/apt/lists/*
    c31865d83ea1        8 days ago          /bin/sh -c echo '#!/bin/sh' > /usr/sbin/polic
    8cbdf71a8e7f        8 days ago          /bin/sh -c #(nop) ADD file:c0f316fa0dcbdd4635
    511136ea3c5a        16 months ago


<!SLIDE>
# Section summary

We've learned how to:

* Understand how ``docker diff``, ``docker tag``, and ``docker commit`` are used.
* Understand how a layer is constructed in an image.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Create a new container and make some changes
To start, launch a terminal inside of a ``ubuntu`` container in interactive mode:

    @@@ Sh
    $ docker run -it ubuntu bash
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
    c3d5614fecc4        8 days ago          /bin/sh -c #(nop) CMD [/bin/bash]
    96e1c132acb3        8 days ago          /bin/sh -c apt-get update && apt-get dist-upg
    311ec46308da        8 days ago          /bin/sh -c sed -i 's/^#\s*\(deb.*universe\)$/
    1b2af7d5307a        8 days ago          /bin/sh -c rm -rf /var/lib/apt/lists/*
    c31865d83ea1        8 days ago          /bin/sh -c echo '#!/bin/sh' > /usr/sbin/polic
    8cbdf71a8e7f        8 days ago          /bin/sh -c #(nop) ADD file:c0f316fa0dcbdd4635
    511136ea3c5a        16 months ago
