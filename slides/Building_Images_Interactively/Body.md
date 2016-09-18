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

<!SLIDE pprintonly>
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
