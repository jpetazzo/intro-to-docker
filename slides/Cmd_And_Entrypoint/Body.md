<!SLIDE>
# Defining a default command

When people run our container, we want to automatically execute
`wget` to retrieve our public IP address, using ifconfig.me.

For that, we will execute:

    @@@ Sh
    wget -O- -q http://ifconfig.me/ip

* `-O-` tells wget to output to standard output instead of a file.
* `-q` tells wget to skip verbose output and give us only the data.
* `http://ifconfig.me/ip` is the URL we want to retrieve.

<!SLIDE>
# Adding `CMD` to our Dockerfile

Our new Dockerfile will look like this:

    @@@ docker
    FROM ubuntu
    RUN apt-get update
    RUN apt-get install -y wget
    CMD wget -O- -q http://ifconfig.me/ip

* `CMD` defines a default command to run when none is given.
* It can appear at any point in the file.
* Each `CMD` will replace and override the previous one.
* As a result, while you can have multiple `CMD` lines, it is useless.

<!SLIDE>
# Build and test our image

Let's build it:

    @@@ Sh
    $ docker build -t ifconfigme .
    ...
    Successfully built 042dff3b4a8d

And run it:

    @@@ Sh
    $ docker run ifconfigme
    64.134.229.24

<!SLIDE>
# Overriding `CMD`

If we want to get a shell into our container (instead of running
`wget`), we just have to specify a different program to run:

    @@@ Sh
    $ docker run -it ifconfigme bash
    root@7ac86a641116:/# 

* We specified `bash`.
* It replaced the value of `CMD`.

<!SLIDE>
# Using `ENTRYPOINT`

We want to be able to specify a different URL on the command line,
while retaining `wget` and some default parameters.

In other words, we would like to be able to do this:

    @@@ Sh
    $ docker run ifconfigme http://ifconfig.me/ua
    Wget/1.12 (linux-gnu)

We will use the `ENTRYPOINT` verb in Dockerfile.

<!SLIDE>
# Adding `ENTRYPOINT` to our Dockerfile

Our new Dockerfile will look like this:

    @@@ docker
    FROM ubuntu
    RUN apt-get update
    RUN apt-get install -y wget
    ENTRYPOINT ["wget", "-O-", "-q"]

* `ENTRYPOINT` defines a base command (and its parameters) for the container.
* The command line arguments are appended to those parameters.
* Like `CMD`, `ENTRYPOINT` can appear anywhere, and replaces the previous value.

<!SLIDE>
# Build and test our image

Let's build it:

    @@@ Sh
    $ docker build -t ifconfigme .
    ...
    Successfully built 36f588918d73

And run it:

    @@@ Sh
    $ docker run ifconfigme http://ifconfig.me/ua
    Wget/1.12 (linux-gnu)

Great success!

<!SLIDE>
# Using `CMD` and `ENTRYPOINT` together

What if we want to define a default URL for our container?

Then we will use `ENTRYPOINT` and `CMD` together.

* `ENTRYPOINT` will define the base command for our container.
* `CMD` will define the default parameter(s) for this command.

<!SLIDE>
# `CMD` and `ENTRYPOINT` together

Our new Dockerfile will look like this:

    @@@ docker
    FROM ubuntu
    RUN apt-get update
    RUN apt-get install -y wget
    ENTRYPOINT ["wget", "-O-", "-q"]
    CMD http://ifconfig.me/ip

* `ENTRYPOINT` defines a base command (and its parameters) for the container.
* If we don't specify extra command-line arguments when starting the container,
  the value of `CMD` is appended.
* Otherwise, our extra command-line arguments are used instead of `CMD`.

<!SLIDE>
# Build and test our image

Let's build it:

    @@@ Sh
    $ docker build -t ifconfigme .
    ...
    Successfully built 6e0b6a048a07

And run it:

    @@@ Sh
    $ docker run ifconfigme
    64.134.229.24
    $ docker run ifconfigme http://ifconfig.me/ua
    Wget/1.12 (linux-gnu)

<!SLIDE>
# Overriding `ENTRYPOINT`

What if we want to run a shell in our container?

We cannot just do `docker run ifconfigme bash` because
that would try to fetch the URL `bash` (which is not
a valid URL, obviously).

We use the `--entrypoint` parameter:

    @@@ Sh
    $ docker run -it --entrypoint bash ifconfigme
    root@6027e44e2955:/# 

