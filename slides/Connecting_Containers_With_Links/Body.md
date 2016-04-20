<!SLIDE>
# How *links* work

* Links are created *between two containers*
* Links are created *from the client to the server*
* Links associate an arbitrary name to an existing container
* Links exist *only in the context of the client*

Let's see them in action.

<!SLIDE>
# The plan

* We will create the `redis` container first.
* Then, we will create the `www` container, *with a link to the previous container.*
* We don't need to use a custom network for this to work.

<!SLIDE>
# Create the `redis` container

Let's launch a container from the `redis` image.

    @@@ Sh
    $ docker run -d --name datastore redis
    <yourContainerID>

Let's check the container is running:

    @@@ Sh
    $ docker ps -l
    CONTAINER ID   IMAGE          COMMAND        ...   PORTS      NAMES
    9efd72a4f320   redis:latest   redis-server   ...   6379/tcp   datastore


* Our container is launched and running an instance of Redis.
* We used the `--name` flag to reference our container easily later.
* We could have used *any name we wanted.*

<!SLIDE>
# Create the `www` container

If we create the web container without any extra option, it will not be able to connect to redis.

    @@@ Sh
    $ docker run -dP jpetazzo/trainingwheels

Check the port number with `docker ps`, and connect to it.

We get the same red error page as before.

<!SLIDE>
# How our app connects to Redis

Remember, in the code, we connect to the name `redis`:

    @@@ Python
    redis = redis.Redis("redis")

* This means "try to connect to 'redis'".
* Not 192.168.123.234.
* Not redis.prod.mycompany.net.

*Obviously* it doesn't work.

<!SLIDE>
# Creating a linked container

Docker allows to specify *links*.

Links indicate an intent: "this container will connect to this other container."

Here is how to create our first link:

    @@@ Sh
    $ docker run -ti --link datastore:redis alpine sh

In this container, we can communicate with `datastore` using
the `redis` DNS alias.

<!SLIDE>
# DNS

Docker has created a DNS entry for the container, resolving to its internal IP address.

    @@@ Sh
    $ docker run -it --link datastore:redis alpine ping redis
    PING redis (172.17.0.29): 56 data bytes
    64 bytes from 172.17.0.29: icmp_seq=0 ttl=64 time=0.164 ms
    64 bytes from 172.17.0.29: icmp_seq=1 ttl=64 time=0.122 ms
    64 bytes from 172.17.0.29: icmp_seq=2 ttl=64 time=0.086 ms
    ^C--- redis ping statistics ---
    3 packets transmitted, 3 packets received, 0% packet loss
    round-trip min/avg/max/stddev = 0.086/0.124/0.164/0.032 ms


* The ``--link`` flag connects one container to another.
* We specify the name of the container to link to, ``datastore``, and an
  alias for the link, ``redis``, in the format ``name:alias``.

<!SLIDE>
# Starting our application

Now that we've poked around a bit let's start the application itself in
a fresh container:

    @@@ Sh
    $ docker run -d -P --link datastore:redis jpetazzo/trainingwheels

Now let's check the port number associated to the container.

    @@@ Sh
    $ docker ps -l

<!SLIDE>
# Confirming that our application works properly

Finally, let's browse to our application and confirm it's working.

    @@@ Sh
    http://<yourHostIP>:<port>

<!SLIDE>
# Links and environment variables

In addition to the DNS information, Docker will automatically set environment variables in our container, giving extra details about the linked container.

    @@@ Sh
    $ docker run --link datastore:redis alpine env
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    HOSTNAME=0738e57b771e
    REDIS_PORT=tcp://172.17.0.120:6379
    REDIS_PORT_6379_TCP=tcp://172.17.0.120:6379
    REDIS_PORT_6379_TCP_ADDR=172.17.0.120
    REDIS_PORT_6379_TCP_PORT=6379
    REDIS_PORT_6379_TCP_PROTO=tcp
    REDIS_NAME=/dreamy_wilson/redis
    REDIS_ENV_REDIS_VERSION=2.8.13
    REDIS_ENV_REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-2.8.13.tar.gz
    REDIS_ENV_REDIS_DOWNLOAD_SHA1=a72925a35849eb2d38a1ea076a3db82072d4ee43
    HOME=/
    RUBY_MAJOR=2.1
    RUBY_VERSION=2.1.2


* Each variables is prefixed with the link alias: ``redis``.
* Includes connection information PLUS any environment variables set in
  the ``datastore`` container via ``ENV`` instructions.

<!SLIDE>
# Differences between network aliases and links

* With network aliases, you can start containers in *any order.*
* With links, you have to start the server (in our example: Redis) first.
* With network aliases, you cannot change the name of the server once it is running. If you want to add a name, you have to create a new container.
* With links, you can give new names to an existing container.
* Network aliases require the use of a custom network.
* Links can be used on the default bridge network.
* Network aliases work across multi-host networking.
* Links (as of Engine 1.10) only work with local containers (but this might be changed in the future).
* Network aliases don't populate environment variables.
* Links give access to the environment of the target container.

<!SLIDE>
# Section summary

We've learned how to:

* Create links between containers.
* Use names and links to communicate across containers.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Pull the ``redis`` image

    @@@ Sh
    $ docker pull redis:latest
    $ docker images redis
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    redis               latest              b73cdc045d3c        2 weeks ago         98.42 MB


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Start a Redis container

    @@@ Sh
    $ docker run -d --name datastore redis
    <yourContainerId>
    $ docker ps -l
    CONTAINER ID             IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    <yourContainerId>        redis:latest        redis-server        5 seconds ago       Up 4 seconds        6379/tcp            datastore


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Pull Rails application image

    @@@ Sh
    $ docker pull nathanleclaire/redisonrails

When it's done downloading, review it.

    @@@ Sh
    $ docker images nathanleclaire/redisonrails


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Try starting Rails container without links

Try interacting with `$redis` in the rails container without links.  It will 
fail.

    @@@ Sh
    $ docker run -it nathanleclaire/redisonrails rails console
    Loading development environment (Rails 4.0.2)
    irb(main):001:0> $redis
    => #<Redis client v3.1.0 for redis://redis:6379/0>
    irb(main):002:0> $redis.set('foo', 'bar')
    SocketError: getaddrinfo: Name or service not known
        from /usr/local/lib/ruby/gems/2.1.0/gems/redis-3.1.0/lib/redis/connection/ruby.rb:152:in `getaddrinfo'
        from /usr/local/lib/ruby/gems/2.1.0/gems/redis-3.1.0/lib/redis/connection/ruby.rb:152:in `connect'
        from /usr/local/lib/ruby/gems/2.1.0/gems/redis-3.1.0/lib/redis/connection/ruby.rb:211:in `connect'
        from /usr/local/lib/ruby/gems/2.1.0/gems/redis-3.1.0/lib/redis/client.rb:304:in `establish_connection'
        .....


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Start Rails container with links

Try interacting with ``$redis`` _with_ links.  It will work. 

    @@@ Sh
    $ docker run -it  --link datastore:redis \
      nathanleclaire/redisonrails rails console
    Loading development environment (Rails 4.0.2)
    irb(main):001:0> $redis
    => #<Redis client v3.1.0 for redis://redis:6379/0>
    irb(main):002:0> $redis.set('a', 'b')
    => "OK"
    irb(main):003:0> $redis.get('a')
    => "b"
    irb(main):004:0> $redis.set('someHash', {:foo => 'bar', :spam => 'eggs'})
    => "OK"
    irb(main):005:0> $redis.get('someHash')
    => "{:foo=>\"bar\", :spam=>\"eggs\"}"
    irb(main):006:0> $redis.set('users', ['Aaron', 'Jerome', 'Nathan'])
    => "OK"
    irb(main):007:0> $redis.get('users')
    => "[\"Aaron\", \"Jerome\", \"Nathan\"]"
    irb(main):008:0> exit


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: See links environment variables

    @@@ Sh
    $ docker run --link datastore:redis nathanleclaire/redisonrails env
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    HOSTNAME=0738e57b771e
    REDIS_PORT=tcp://172.17.0.120:6379
    REDIS_PORT_6379_TCP=tcp://172.17.0.120:6379
    REDIS_PORT_6379_TCP_ADDR=172.17.0.120
    REDIS_PORT_6379_TCP_PORT=6379
    REDIS_PORT_6379_TCP_PROTO=tcp
    REDIS_NAME=/dreamy_wilson/redis
    REDIS_ENV_REDIS_VERSION=2.8.13
    REDIS_ENV_REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-2.8.13.tar.gz
    REDIS_ENV_REDIS_DOWNLOAD_SHA1=a72925a35849eb2d38a1ea076a3db82072d4ee43
    HOME=/
    RUBY_MAJOR=2.1
    RUBY_VERSION=2.1.2


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: See links DNS entry work

    @@@ Sh
    $ docker run -it --link datastore:redis nathanleclaire/redisonrails ping redis
    PING redis (172.17.0.29): 56 data bytes
    64 bytes from 172.17.0.29: icmp_seq=0 ttl=64 time=0.164 ms
    64 bytes from 172.17.0.29: icmp_seq=1 ttl=64 time=0.122 ms
    64 bytes from 172.17.0.29: icmp_seq=2 ttl=64 time=0.086 ms
    ^C--- redis ping statistics ---
    3 packets transmitted, 3 packets received, 0% packet loss
    round-trip min/avg/max/stddev = 0.086/0.124/0.164/0.032 ms


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Start our linked Rails application

    @@@ Sh
    $ docker run -d -p 80:3000 --link datastore:redis nathanleclaire/redisonrails

To verify that it is running:

    @@@ Sh
    $ docker ps -l


<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Visit our linked Rails application

Finally, let's browse to our application and confirm it's working.

    @@@ Sh
    http://<yourHostIP>

![redisonrails](redisonrails.png)
