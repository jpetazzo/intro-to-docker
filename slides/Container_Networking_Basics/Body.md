<!SLIDE>
# A simple, static web server

Run the Docker Hub image `jpetazzo/web`, which contains a basic web server:

    @@@ Sh
    $ docker run -d -P jpetazzo/web
    66b1ce719198711292c8f34f84a7b68c3876cf9f67015e752b94e189d35a204e

* Docker will download the image from the Docker Hub.
* `-d` tells Docker to run the image in the background.
* `-P` tells Docker to make this service reachable from other computers.
  <br/>(`-P` is the short version of `--publish-all`.)

But, how do we connect to our web server now?

<!SLIDE>
# Finding our web server port

We will use `docker ps`:

    @@@ Sh
    $ docker ps
    CONTAINER ID  IMAGE                ...     PORTS                    ...
    66b1ce719198  jpetazzo/web:latest  ...     0.0.0.0:49153->8000/tcp  ...

* The web server is running on port 8000 inside the container.
* That port is exposed on port 49153 on our Docker host.

We will explain the whys and hows of this port mapping.

But first, let's make sure that everything works properly.

<!SLIDE>
# Connecting to our web server (GUI)

Point your browser to the IP address of your Docker host, on the port
shown by `docker ps`.

![Screenshot](web.png)

<!SLIDE>
# Connecting to our web server (CLI)

You can also use `curl` directly from the Docker host.

Make sure to use the right port number if it is different
from the example below:

    @@@ Sh
    $ curl localhost:49153
    Hello, world!


<!SLIDE>
# Docker network model

* We are out of IPv4 addresses.
* Containers cannot have public IPv4 addresses.
* They have private addresses.
* Services have to be exposed port by port.
* Ports have to be mapped to avoid conflicts.

<!SLIDE>
# Finding the web server port in a script

Parsing the output of `docker ps` would be painful.

There is a command to help us:

    @@@ Sh
    $ docker port <containerID> 8000
    49153

<!SLIDE>
# Manual allocation of port numbers

If you want to set port numbers yourself, no problem:

    @@@ Sh
    $ docker run -t -p 80:8000 jpetazzo/web

* This time, we are running our container in the foreground.
  <br/>(That way, we can kill it easily with `^C`.)
* We mapped port 80 on the host, to port 8000 in the container.

<!SLIDE>
# Plumbing containers into your infrastructure

There are (at least) three ways to integrate containers in your network.

* Start the container, letting Docker allocate a public port for it.
  <br/>Then retrieve that port number and feed it to your configuration.
* Pick a fixed port number in advance, when you generate your configuration.
  <br/>Then start your container by setting the port numbers manually.
* Use an overlay network, connecting your containers with e.g. VLANs, tunnels...

<!SLIDE>
# Finding the container's IP address

We can use the `docker inspect` command to find the IP address of the
container.

    @@@ Sh
    $ docker inspect --format '{{ .NetworkSettings.IPAddress }}' <yourContainerID>
    172.17.0.3

* `docker inspect` is an advanced command, that can retrieve a ton
  of information about our containers.
* Here, we provide it with a format string to extract exactly the
  private IP address of the container.

<!SLIDE>
# Pinging our container

We can test connectivity to the container using the IP address we've
just discovered. Let's see this now by using the ``ping`` tool.

    @@@ Sh
    $ ping <ipAddress>
    64 bytes from <ipAddress>: icmp_req=1 ttl=64 time=0.085 ms
    64 bytes from <ipAddress>: icmp_req=2 ttl=64 time=0.085 ms
    64 bytes from <ipAddress>: icmp_req=3 ttl=64 time=0.085 ms

<!SLIDE>
# Section summary

We've learned how to:

* Expose a network port.
* Manipulate container networking basics.
* Find a container's IP address.

**NOTE: Later on we'll see how to network containers without exposing ports
using the ``link`` primitive.**

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Create a container

1. Create a new container.

         @@@ Sh
         $ docker run -d -p 80 training/webapp python -m SimpleHTTPServer 80

2. Make a note of the container ID.

3. Check the container is running.

         @@@ Sh
         $ docker ps

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Checking the container's port mapping

1. Retrieve the container's port mapping.

         @@@ Sh
         $ docker port <yourContainerId> 80

2. Note also that you can get this information using ``docker inspect -f``:

         @@@ Sh
         $ docker inspect -f "{{ json .NetworkSettings.Ports }}" <yourContainerID>
         {"5000/tcp":null,"80/tcp":[{"HostIp":"0.0.0.0","HostPort":"49153"}]}

2. Make a note of the port number returned.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Browse to the web server

1. Browse to the URL.

        @@@ Sh
        http://<yourHostIP>:<portNumber>

2. You should see a directory listing for your container.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Finding the container's IP address

1. Now retrieve the container's IP address.

        @@@ Sh
        $ docker inspect --format \
          '{{ .NetworkSettings.IPAddress }}' \
          <yourContainerId>

2. Make a note of the IP address returned.

3. Ping the IP address.

        @@@ Sh
        $ ping <ipAddress>

4. You should see a response.

        @@@ Sh
        64 bytes from <ipAddress>: icmp_req=2 ttl=64 time=0.085 ms
        64 bytes from <ipAddress>: icmp_req=2 ttl=64 time=0.085 ms
