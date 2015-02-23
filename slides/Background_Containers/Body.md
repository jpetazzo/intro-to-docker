<!SLIDE>
# A non-interactive container

We will run a small custom container.

This container just displays the time every second.

    @@@ Sh
    $ docker run jpetazzo/clock
    Fri Feb 20 00:28:53 UTC 2015
    Fri Feb 20 00:28:54 UTC 2015
    Fri Feb 20 00:28:55 UTC 2015
    ...

* This container will run forever.
* To stop it, press `^C`.
* Docker has automatically downloaded the image `jpetazzo/clock`.
* This image is a user image, created by `jpetazzo`.
* We will tell more about user images (and other types of images) later.

<!SLIDE>
# Run a container in the background

Containers can be started in the background, with the `-d` flag (daemon mode):

    @@@ Sh
    $ docker run -d jpetazzo/clock
    47d677dcfba4277c6cc68fcaa51f932b544cab1a187c853b7d0caf4e8debe5ad

* We don't see the output of the container.
* But don't worry: Docker collects that output and logs it!
* Docker gives us the ID of the container.

<!SLIDE>
# List running containers

How can we check that our container is still running?

With `docker ps`, just like the UNIX `ps` command, lists running processes.

    @@@ Sh
    $ docker ps
    CONTAINER ID  IMAGE                  COMMAND  CREATED        STATUS        ...
    47d677dcfba4  jpetazzo/clock:latest  ...      2 minutes ago  Up 2 minutes  ...

Docker tells us:

* The (truncated) ID of our container.
* The image used to start the container.
* That our container has been running (`Up`) for a couple of minutes.
* Other information (COMMAND, PORTS, NAMES) that we will explain later.

<!SLIDE>
# Two useful flags for `docker ps`

To see only the last container that was started:

    @@@ Sh
    $ docker ps -l
    CONTAINER ID  IMAGE                  COMMAND  CREATED        STATUS        ...
    47d677dcfba4  jpetazzo/clock:latest  ...      2 minutes ago  Up 2 minutes  ...

To see only the ID of containers:

    @@@ Sh
    $ docker ps -q
    47d677dcfba4
    66b1ce719198
    ee0255a5572e

Combine those flags to see only the ID of the last container started!

    @@@ Sh
    $ docker ps -q
    47d677dcfba4

<!SLIDE>
# View the logs of a container

We told you that Docker was logging the container output.

Let's see that now.

    @@@ Sh
    $ docker logs 47d6
    Fri Feb 20 00:39:52 UTC 2015
    Fri Feb 20 00:39:53 UTC 2015
    ...

* We specified a *prefix* of the full container ID.
* You can, of course, specify the full ID. 
* The `logs` command will output the *entire* logs of the container.
  <br/>(Sometimes, that will be too much. Let's see how to address that.)

<!SLIDE>
# View only the tail of the logs

To avoid being spammed with eleventy pages of output,
we can use the `--tail` option:

    @@@ Sh
    $ docker logs --tail 3 47d6
    Fri Feb 20 00:55:35 UTC 2015
    Fri Feb 20 00:55:36 UTC 2015
    Fri Feb 20 00:55:37 UTC 2015

* The parameter is the number of lines that we want to see.

<!SLIDE>
# Follow the logs in real time

Just like with the standard UNIX command `tail -f`, we can
follow the logs of our container:

    @@@ Sh
    $ docker logs --tail 1 --follow 47d6
    Fri Feb 20 00:57:12 UTC 2015
    Fri Feb 20 00:57:13 UTC 2015
    ^C

* This will display the last line in the log file.
* Then, it will continue to display the logs in real time.
* Use `^C` to exit.

<!SLIDE>
# Stop our container

There are two ways we can terminate our detached container.

* Killing it using the `docker kill` command.
* Stopping it using the `docker stop` command.

The first one stops the container immediately, by using the
`KILL` signal.

The second one is more graceful. It sends a `TERM` signal,
and after 10 seconds, if the container has not stopped, it
sends `KILL.`

Reminder: the `KILL` signal cannot be intercepted, and will
forcibly terminate the container.

<!SLIDE>
# Killing it

Let's kill our container:

    @@@ Sh
    $ docker kill 47d6
    47d6

Docker will echo the ID of the container we've just stopped.

Let's check that our container doesn't show up anymore:

    @@@ Sh
    $ docker ps

<!SLIDE>
# List stopped containers

We can also see stopped containers, with the `-a` (`--all`) option.

    @@@ Sh
    $ docker ps -a
    CONTAINER ID  IMAGE                  ...  CREATED      STATUS
    47d677dcfba4  jpetazzo/clock:latest  ...  23 min. ago  Exited (0) 4 min. ago
    5c1dfd4d81f1  jpetazzo/clock:latest  ...  40 min. ago  Exited (0) 40 min. ago
    b13c164401fb  ubuntu:latest          ...  55 min. ago  Exited (130) 53 min. ago
