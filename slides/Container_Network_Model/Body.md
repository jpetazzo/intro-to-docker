<!SLIDE>
# The Container Network Model

The CNM was introduced in Engine 1.9.0.

DON'T PANIC: all the previous drivers shown in the previous chapter are still available.

Docker now has the notion of a *network*, and a new top-level command to manipulate and see those networks: `docker network`.

    @@@ Sh
    $ docker network ls
    NETWORK ID          NAME                DRIVER
    6bde79dfcf70        bridge              bridge
    8d9c78725538        none                null
    eb0eeab782f4        host                host
    4c1ff84d6d3f        skynet              bridge
    228a4355d548        darknet             overlay
    3f1733d3e233        darkernet           overlay

<!SLIDE>
# What's in a network?

* Conceptually, a network is a virtual switch.
* It can be local (to a single Engine) or global (across multiple hosts).
* A network has an IP subnet associated to it.
* A network is managed by a *driver*.
* A network can have a custom IPAM (IP allocator).
* Containers with explicit names are discoverable via DNS.
* All the drivers that we have seen before are available.
* A new multi-host driver, *overlay*, is available out of the box.
* More drivers can be provided by plugins (OVS, VLAN...)

<!SLIDE>
# Creating a network

Let's create a network.

    @@@ Sh
    $ docker network create skynet
    4c1ff84d6d3f1733d3e233ee039cac276f425a9d5228a4355d54878293a889ba

The network is now visible with the `network ls` command:

    @@@ Sh
    $ docker network ls
    NETWORK ID          NAME                DRIVER
    6bde79dfcf70        bridge              bridge
    8d9c78725538        none                null
    eb0eeab782f4        host                host
    4c1ff84d6d3f        skynet              bridge

<!SLIDE>
# Placing containers on a network

We will create two *named* containers on this network.

First, let's create this container in the background.

    @@@ Sh
    $ docker run -dti --name t800 --net skynet alpine sh
    8abb80e229ce8926c7223beb69699f5f34d6f1d438bfc5682db893e798046863

Now, create this other container in the foreground.

    @@@ Sh
    $ docker run -ti --name t1000 --net skynet ubuntu
    root@0ecccdfa45ef:/#

<!SLIDE>
# Communication between containers

From our new container (t1000), we can resolve and ping the other one, using its assigned name:

    @@@ Sh
    root@0ecccdfa45ef:/# ping t800
    PING t800 (172.18.0.2) 56(84) bytes of data.
    64 bytes from t800 (172.18.0.2): icmp_seq=1 ttl=64 time=0.221 ms
    64 bytes from t800 (172.18.0.2): icmp_seq=2 ttl=64 time=0.114 ms
    64 bytes from t800 (172.18.0.2): icmp_seq=3 ttl=64 time=0.114 ms
    ^C
    --- t800 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 2000ms
    rtt min/avg/max/mdev = 0.114/0.149/0.221/0.052 ms
    root@0ecccdfa45ef:/#

How did that work?

<!SLIDE>
# Resolving container addresses

In Docker Engine 1.9, name resolution is implemented with /etc/hosts, and
updating it each time containers are added/removed.

    @@@ Sh
    root@0ecccdfa45ef:/# cat /etc/hosts
    172.18.0.3  0ecccdfa45ef
    127.0.0.1       localhost
    ::1     localhost ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    172.18.0.2      t800
    172.18.0.2      t800.skynet

In Docker Engine 1.10, this has been replaced by a dynamic resolver.

(This avoids race conditions when updating /etc/hosts.)

<!SLIDE>
# Connecting to multiple networks

Let's create another network.

    @@@ Sh
    $ docker network create resistance
    955b84336816b8e2265a156905aa716f5d1d880516ceaba48b9331f8f4e706aa

Create a container in this network.

    @@@ Sh
    $ docker run --net resistance -ti --name sarahconnor ubuntu
    root@4937d654a579:/# 

This container cannot ping t800 (try it).

Now, from another terminal, connect t800 to the resistance:

    @@@ Sh
    $ docker network connect resistance t800

Then try again to ping t800 from sarahconnor. It works!

<!SLIDE>
# Implementation details

With the "bridge" network driver, each container joining a network receives a new virtual interface.

Each container receives a new virtual interface:

    @@@ Sh
    $ docker run --net container:t800 alpine ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
           valid_lft forever preferred_lft forever
    73: eth0@if74: <BROADCAST,MULTICAST,...> mtu 1500 qdisc noqueue state UP 
        link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff
        inet 172.18.0.2/16 scope global eth0
           valid_lft forever preferred_lft forever
        inet6 fe80::42:acff:fe12:2/64 scope link 
           valid_lft forever preferred_lft forever
    84: eth1@if85: <BROADCAST,MULTICAST,...> mtu 1500 qdisc noqueue state UP 
        link/ether 02:42:ac:13:00:03 brd ff:ff:ff:ff:ff:ff
        inet 172.19.0.3/16 scope global eth1
           valid_lft forever preferred_lft forever
        inet6 fe80::42:acff:fe13:3/64 scope link 
           valid_lft forever preferred_lft forever

<!SLIDE>
# Custom networks

* When creating a network, extra options can be provided.
* `--internal` disables outbound traffic (the network won't have a default gateway).
* `--gateway` indicates which address to use for the gateway (when utbound traffic is allowed).
* `--subnet` (in CIDR notation) indicates the subnet to use.
* `--ip-range` (in CIDR notation) indicates the subnet to allocate from.
* `--aux-address` allows to specify a list of reserved addresses (which won't be allocated to containers).

<!SLIDE>
# Setting containers' IP address

* It is possible to set a container's address with `--ip`.
* The IP address has to be within the subnet used for the container.

A full example would look like this.

    @@@ Sh
    $ docker network create --subnet 10.66.0.0/16 pubnet
    42fb16ec412383db6289a3e39c3c0224f395d7f85bcb1859b279e7a564d4e135
    $ docker run --net pubnet --ip 10.66.66.66 -d nginx
    b2887adeb5578a01fd9c55c435cad56bbbe802350711d2743691f95743680b09

*Note: don't hard code container IP addresses in your code!*

*I repeat: don't hard code container IP addresses in your code!*

<!SLIDE>
# Connecting multiple containers together

* Let's try to run an application that requires two containers.
* The first container is a web server.
* The other one is a redis data store.
* We will place them both on the `skynet` network created before.

<!SLIDE>
# Running the web server

* The application is provided by the container image `jpetazzo/trainingwheels`.
* We don't know much about it so we will try to run it and see what happens!

Start the container, exposing all its ports:

    @@@ Sh
    $ docker run --net skynet -d -P jpetazzo/trainingwheels

Check the port that has been allocated to it:

    @@@ Sh
    $ docker ps -l

<!SLIDE>
# Test the web server

* If we connect to the application now, we will see an error page:

![Trainingwheels error](trainingwheels-error.png)

* This is because the Redis service is not running.
* This container tries to resolve the name `redis`.

Note: we're not using a FQDN or an IP address here; just `redis`.

<!SLIDE>
# Start the data store

* We need to start a Redis container.
* That container must be on the same network as the web server.
* It must have the right name (`redis`) so the application can find it.

Start the container:

    @@@ Sh
    $ docker run --net skynet --name redis -d redis

<!SLIDE>
# Test the web server again

* If we connect to the application now, we should see that the app is working correctly:

![Trainingwheels OK](trainingwheels-ok.png)

* When the app tries to resolve `redis`, instead of getting a DNS error, it gets the IP address of our Redis container.

<!SLIDE>
# A few words on *scope*

* What if we want to run multiple copies of our application?
* Since names are unique, there can be only one container named `redis` at a time.
* We can specify `--net-alias` to define network-scoped aliases, independently of the container name.

Let's remove the `redis` container:

    @@@ Sh
    $ docker rm -f redis

And create one that doesn't block the `redis` name:

    @@@ Sh
    $ docker run --net skynet --net-alias redis -d redis

Check that the app still works (but the counter is back to 1,
since we wiped out the old Redis container).

<!SLIDE>
# Good to know ...

* Docker will not create network names and aliases on the default `bridge` network.
* Therefore, if you want to use those features, you have to create a custom network first.
* Network aliases are *not* unique: you can give multiple containers the same alias *on the same network.*
* In that case, as of Engine 1.10, one container will be selected and only its IP address will be returned when resolving the network alias.

Note: future versions of the Engine might implement DNS round robin instead, or even load balancing.

<!SLIDE>
# Overlay networks

* The features we've seen so far only work when all containers are on a single host.
* If containers span multiple hosts, we need an *overlay* network to connect them together.
* Docker ships with a default network plugin, `overlay`, implementing an overlay network leveraging VXLAN and a key/value store.
* Other plugins (Weave, Calico...) can provide overlay networks as well.
* Once you have an overlay network, *all the features that we've used in this chapter work identically.*

<!SLIDE>
# Multi-host networking (overlay)

Out of the scope for this intro-level workshop!

Very short instructions:

- deploy a key/value store (Consul, Etc, or Zookeeper)
- add two extra flags to your Docker Engine
- you can now create networks using the overlay driver!

When you create a network on one host with the overlay driver, it
appears automatically on all other hosts.

Containers placed on the same networks are able to resolve and
ping as if they were local.

The overlay network is based on VXLAN and stores neighbor info
in the key/value store.

<!SLIDE>
# Multi-host networking (plugins)

Out of the scope for this intro-level workshop!

General idea:

- install the plugin (they often ship within containers)
- run the plugin (if it's in a container, it will often require extra parameters; don't just `docker run` it blindly!)
- some plugins require configuration or activation (creating a special file that tells Docker "use the plugin whose control socket is at the following location")
- you can then `docker network create --driver pluginname`

<!SLIDE>
# Section summary

We've learned how to:

* Create private networks for groups of containers.
* Assign IP addresses to containers.
* Use container naming to implement service discovery.

