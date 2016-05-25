<!SLIDE>
# Ambassadors

We've already seen a couple of ways we can manage our application
architecture in Docker.

* With network aliases.
* With links.

We're now going to see a pattern for service portability we call:
ambassadors.

<!SLIDE>
# Introduction to Ambassadors

The ambassador pattern:

* Takes advantage of Docker's per-container naming system and abstracts
  connections between services.
* Allows you to manage services without hard-coding connection
  information inside applications.

To do this, instead of directly connecting containers you insert
ambassador containers.

<!SLIDE>

![ambassador](diagram.png)

<!SLIDE>
# Interacting with ambassadors

* The web application container uses a normal link to connect
  to the ambassador.
* The database container is linked with an ambassador as well.
* For both containers, there is no difference between normal
  operation and operation with ambassador containers.
* If the database container is moved, its new location will
  be tracked by the ambassador containers, and the web application
  container will still be able to connect, without reconfiguration.

<!SLIDE>
# Ambassadors for simple service discovery

Use case:

* my application code connects to `redis` on the default port (6379),
* my Redis service runs on another machine, on a non-default port (e.g. 12345),
* I want to use an ambassador to let my application connect without modification.

The ambassador will be:

* a container running right next to my application,
* using the name `redis` (or linked as `redis`),
* listening on port 6379,
* forwarding connections to the actual Redis service.

<!SLIDE>
# Ambassadors for service migration

Use case:

* my application code still connects to `redis`,
* my Redis service runs somewhere else,
* my Redis service is moved to a different host+port,
* the location of the Redis service is given to me via e.g. DNS SRV records,
* I want to use an ambassador to automatically connect to the new location, with as little disruption as possible.

The ambassador will be:

* the same kind of container as before,
* running an additional routine to monitor DNS SRV records,
* updating the forwarding destination when the DNS SRV records are updated.

<!SLIDE>
# Ambassadors for credentials injection

Use case:

* my application code still connects to `redis`,
* my application code doesn't provide Redis credentials,
* my production Redis service requires credentials,
* my staging Redis service requires different credentials,
* I want to use an ambassador to abstract those credentials.

The ambassador will be:

* a container using the name `redis` (or a link),
* passed the credentials to use,
* running a custom proxy that accepts connections on Redis default port,
* performing authentication with the target Redis service before forwarding traffic.

<!SLIDE>
# Ambassadors for load balancing

Use case:

* my application code connects to a web service called `api`,
* I want to run multiple instances of the `api` backend,
* those instances will be on different machines and ports,
* I want to use an ambassador to abstract those details.

The ambassador will be:

* a container using the name `api` (or a link),
* passed the list of backends to use (statically or dynamically),
* running a load balancer (e.g. HAProxy or NGINX),
* dispatching requests across all backends transparently.

<!SLIDE>
# "Ambassador" is a *pattern*

There are many ways to implement the pattern.

Different deployments will use different underlying technologies.

* On-premise deployments with a trusted network can track
  container locations in e.g. Zookeeper, and generate HAproxy
  configurations each time a location key changes.
* Public cloud deployments or deployments across unsafe
  networks can add TLS encryption.
* Ad-hoc deployments can use a master-less discovery protocol
  like avahi to register and discover services.
* It is also possible to do one-shot reconfiguration of the
  ambassadors. It is slightly less dynamic but has much less
  requirements.
* Ambassadors can be used in addition to, or instead of, overlay networks.

<!SLIDE>
# Section summary

We've learned how to:

* Understand the ambassador pattern and what it is used for (service portability).

For more information about the ambassador pattern, including demos on Swarm and ECS: 

* AWS re:invent 2015 [DVO317](https://www.youtube.com/watch?v=7CZFpHUPqXw)
* [SwarmWeek video about Swarm+Compose](https://youtube.com/watch?v=qbIvUvwa6As)

Ambassadors are also covered in depth in the advanced/orchestration workshop.
