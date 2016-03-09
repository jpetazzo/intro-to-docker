<!SLIDE>
# Docker architecture

Docker is a client-server application.

* **The Docker Engine (or "daemon")**
  <br/>Receives and processes incoming Docker API requests.

* **The Docker client**
  <br/>Talks to the Docker daemon via the Docker API.
  <br/>We'll use mostly the CLI embedded within the `docker` binary.
 
* **Docker Hub Registry**
  <br/>Collection of public images.
  <br/>The Docker daemon talks to it via the registry API.
 
<!SLIDE>
# Hello World

In your Docker environment, just run the following command:

    @@@ Sh
    $ docker run busybox echo hello world
    hello world


<!SLIDE>
# That was our first container!

* We used one of the smallest, simplest images available: `busybox`.
* `busybox` is typically used in embedded systems (phones, routers...)
* We ran a single process and echo'ed `hello world`.


<!SLIDE>
# A more useful container

Let's run a more exciting container:

    @@@ Sh
    $ docker run -it ubuntu
    root@04c0bb0a6c07:/#

* This is a brand new container.
* It runs a bare-bones, no-frills `ubuntu` system.
* `-it` is shorthand for `-i -t`.

  * `-i` tells Docker to connect us to the container's stdin.
  * `-t` tells Docker that we want a pseudo-terminal.



<!SLIDE>
# Do something in our container

Try to run `figlet` in our container.

    @@@ Sh
    root@04c0bb0a6c07:/# figlet hello
    bash: figlet: command not found

Alright, we need to install it.

<!SLIDE>
# An obvservation

Let's check how many packages are installed here.

    @@@ Sh
    root@04c0bb0a6c07:/# dpkg -l | wc -l
    189

* `dpkg -l` lists the packages installed in our container
* `wc -l` counts them
* If you have a Debian or Ubuntu machine, you can run the same command 
  and compare the results.

<!SLIDE>
# Install a package in our container

We want `figlet`, so let's install it:

    @@@ Sh
    root@04c0bb0a6c07:/# apt-get update
    ...
    Fetched 1514 kB in 14s (103 kB/s)
    Reading package lists... Done
    root@04c0bb0a6c07:/# apt-get install figlet
    Reading package lists... Done
    ...

One minute later, `figlet` is installed!

    @@@ Sh
    # figlet hello
     _          _ _       
    | |__   ___| | | ___  
    | '_ \ / _ \ | |/ _ \ 
    | | | |  __/ | | (_) |
    |_| |_|\___|_|_|\___/ 


<!SLIDE>
# Exiting our container

Just exit the shell, like you would usually do.

(E.g. with `^D` or `exit`)

    @@@ Sh
    root@04c0bb0a6c07:/# exit

* Our container is now in a *stopped* state.

* It still exists on disk, but all compute resources have been freed up.


<!SLIDE>
# Starting another container

What if we start a new container, and try to run `figlet` again?
 
    @@@ Sh
    $ docker run -it ubuntu
    root@b13c164401fb:/# figlet
    bash: figlet: command not found

* We started a *brand new container*.
* The basic Ubuntu image was used, and `figlet` is not here.
* We will see in the next chapters how to bake a custom image with `figlet`.
   
<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Hello World

1. Run the ``docker run`` command.

        @@@ Sh
        $ docker run busybox echo hello world

2. You should see "hello world" returned to your command line.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Install and run curl in an Ubuntu container

1. Start an Ubuntu container.

        @@@ Sh
        $ docker run -it ubuntu
        root@04c0bb0a6c07:/#

2. Update the package list.

        @@@ Sh
        root@04c0bb0a6c07:/# apt-get update
        ...
        Fetched 1514 kB in 14s (103 kB/s)
        Reading package lists... Done

3. Install `curl`.

        @@@ Sh
        root@04c0bb0a6c07:/# apt-get install curl
        Reading package lists... Done
        ...
        Do you want to continue? [Y/n] 

4. Answer `Y` or just press `Enter` and wait for the package to be installed.

5. Run curl!

        @@@ Sh
	root@04c0bb0a6c07:/# curl ifconfig.me/ip
        64.134.229.24

6. Exit our container.

        @@@ Sh
	root@04c0bb0a6c07:/# exit


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Start a new container

1. Start a new container.

    @@@ Sh
    $ docker run -it ubuntu
    root@b13c164401fb:/#

2. See that `curl` is not in this new container.

    @@@ Sh
    root@b13c164401fb:/# curl
    bash: curl: command not found
