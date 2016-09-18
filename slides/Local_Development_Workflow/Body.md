<!SLIDE>
# Using a Docker container for local development

Never again:

- "Works on my machine"
- "Not the same version"
- "Missing dependency"

By using Docker containers, we will get a consistent development environment.

<!SLIDE>
# Our "namer" application

* The code is available on https://github.com/jpetazzo/namer.
* The image jpetazzo/namer is automatically built by the Docker Hub.

Let's run it with:

    @@@ Sh
    $ docker run -dP jpetazzo/namer

Check the port number with `docker ps` and open the application.


<!SLIDE>
# Let's look at the code

Let's download our application's source code.

    @@@ Sh
    $ git clone https://github.com/jpetazzo/namer
    $ cd namer
    $ ls -1
    company_name_generator.rb
    config.ru
    docker-compose.yml
    Dockerfile
    Gemfile

<!SLIDE>
# Where's my code?

According to the Dockerfile, the code is copied into `/src` :

    FROM ruby
    MAINTAINER Education Team at Docker <education@docker.com>

    COPY . /src
    WORKDIR /src
    RUN bundler install

    CMD ["rackup", "--host", "0.0.0.0"]
    EXPOSE 9292

We want to make changes *inside the container* without rebuilding it each time. 

For that, we will use a *volume*.

<!SLIDE>
# Our first volume

We will tell Docker to map the current directory to `/src` in the container.

    @@@ Sh
    $ docker run -d -v $(pwd):/src -p 80:9292 jpetazzo/namer

* The ``-d`` flag indicates that the container should run in detached mode (in the background).
* The ``-v`` flag provides volume mounting inside containers.
* The ``-p`` flag maps port ``9292`` inside the container to port ``80`` on the host.
* ``jpetazzo/namer`` is the name of the image we will run.
* We don't need to give a command to run because the Dockerfile already specifies `rackup`.

<!SLIDE>
# Mounting volumes inside containers

The ``-v`` flag mounts a directory from your host into your Docker
container. The flag structure is:

    @@@ Sh
    [host-path]:[container-path]:[rw|ro]

* If [host-path] or [container-path] doesn't exist it is created.
* You can control the write status of the volume with the ``ro`` and
  ``rw`` options.
* If you don't specify ``rw`` or ``ro``, it will be ``rw`` by default.

There will be a full chapter about volumes!

<!SLIDE>
# Testing the development container

Now let us see if our new container is running.

    @@@ Sh
    $ docker ps
    CONTAINER ID  IMAGE   COMMAND CREATED       STATUS PORTS                NAMES
    045885b68bc5  trai... rackup  3 seconds ago Up ... 0.0.0.0:80->9292/tcp ...

<!SLIDE>
# Viewing our application

Now let's browse to our web application on:

    @@@ Sh 
    http://<yourHostIP>:80

We can see our company naming application. 

![web application 1](webapp1.png)

<!SLIDE>
# Making a change to our application

Our customer really doesn't like the color of our text. Let's change it.

    @@@ Sh
    $ vi company_name_generator.rb

And change

    @@@ CSS
    color: royalblue;

To:

    @@@ CSS
    color: red;

<!SLIDE>
# Refreshing our application

Now let's refresh our browser:

    @@@ Sh
    http://<yourHostIP>:80

We can see the updated color of our company naming application.

![web application 2](webapp2.png)

<!SLIDE>
# Improving the workflow with Compose

* You can also start the container with the following command:

        @@@ Sh
        $ docker-compose up -d

* This works thanks to the Compose file, `docker-compose.yml`:

        @@@ YAML
        www:
          build: .
          volumes:
            - .:/src
          ports:
            - 80:9292

<!SLIDE>
# Why Compose?

* Specifying all those "docker run" parameters is tedious.
* And error-prone.
* We can "encode" those parameters in a "Compose file."
* When you see a `docker-compose.yml` file, you know that you can use `docker-compose up`.
* Compose can also deal with complex, multi-container apps.
  <br/>(More on this later.)

<!SLIDE>
# Workflow explained

We can see a simple workflow:

1. Build an image containing our development environment.

    (Rails, Django...)

2. Start a container from that image.

    Use the ``-v`` flag to mount source code inside the container.

3. Edit source code outside the containers, using regular tools.

    (vim, emacs, textmate...)

4. Test application.

    (Some frameworks pick up changes automatically.

    Others require you to Ctrl-C + restart after each modification.)

5. Repeat last two steps until satisfied.

6. When done, commit+push source code changes.

    (You *are* using version control, right?)

<!SLIDE pprintonly>
# Debugging inside the container

In 1.3, Docker introduced a feature called `docker exec`.

It allows users to run a new process in a container which is already running.

If sometimes you find yourself wishing you could SSH into a container: you can use `docker exec` instead.

You can get a shell prompt inside an existing container this way, or run an arbitrary process for automation.

<!SLIDE printonly>
# ``docker exec`` example

    @@@ Sh
    $ # You can run ruby commands in the area the app is running and more!
    $ docker exec -it <yourContainerId> bash
    root@5ca27cf74c2e:/opt/namer# irb
    irb(main):001:0> [0, 1, 2, 3, 4].map {|x| x ** 2}.compact
    => [0, 1, 4, 9, 16]
    irb(main):002:0> exit

<!SLIDE pprintonly>
# Stopping the container

Now that we're done let's stop our container.

    @@@ Sh
    $ docker stop <yourContainerID>

And remove it.

    @@@ Sh
    $ docker rm <yourContainerID>

<!SLIDE>
# Section summary

We've learned how to:

* Share code between container and host.
* Set our working directory.
* Use a simple local development workflow.

