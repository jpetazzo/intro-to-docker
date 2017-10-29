---
class: title

# Local Development Workflow with Docker

![construction](Local_Development_Workflow/construction.jpg)
---


### Objectives

At the end of this lesson, you will be able to:

* Share code between container and host.
* Use a simple local development workflow.
---
## Using a Docker container for local development

Never again:

- "Works on my machine"
- "Not the same version"
- "Missing dependency"

By using Docker containers, we will get a consistent development environment.

---
## Our "namer" application

* The code is available on https://github.com/jpetazzo/namer.
* The image jpetazzo/namer is automatically built by the Docker Hub.

Let's run it with:

```bash
$ docker run -dP jpetazzo/namer
```

Check the port number with `docker ps` and open the application.


---
## Let's look at the code

Let's download our application's source code.

```bash
$ git clone https://github.com/jpetazzo/namer
$ cd namer
$ ls -1
company_name_generator.rb
config.ru
docker-compose.yml
Dockerfile
Gemfile
```

---
## Where's my code?

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

---
## Our first volume

We will tell Docker to map the current directory to `/src` in the container.

```bash
$ docker run -d -v $(pwd):/src -p 80:9292 jpetazzo/namer
```

* The `-d` flag indicates that the container should run in detached mode (in the background).
* The `-v` flag provides volume mounting inside containers.
* The `-p` flag maps port `9292` inside the container to port `80` on the host.
* `jpetazzo/namer` is the name of the image we will run.
* We don't need to give a command to run because the Dockerfile already specifies `rackup`.

---
## Mounting volumes inside containers

The `-v` flag mounts a directory from your host into your Docker
container. The flag structure is:

```bash
[host-path]:[container-path]:[rw|ro]
```

* If [host-path] or [container-path] doesn't exist it is created.
* You can control the write status of the volume with the `ro` and
  `rw` options.
* If you don't specify `rw` or `ro`, it will be `rw` by default.

There will be a full chapter about volumes!

---
## Testing the development container

Now let us see if our new container is running.

```bash
$ docker ps
CONTAINER ID  IMAGE   COMMAND CREATED       STATUS PORTS                NAMES
045885b68bc5  trai... rackup  3 seconds ago Up ... 0.0.0.0:80->9292/tcp ...
```

---
## Viewing our application

Now let's browse to our web application on:

```bash 
http://<yourHostIP>:80
```

We can see our company naming application. 

![web application 1](Local_Development_Workflow/webapp1.png)

---
## Making a change to our application

Our customer really doesn't like the color of our text. Let's change it.

```bash
$ vi company_name_generator.rb
```

And change

```css
color: royalblue;
```

To:

```css
color: red;
```

---
## Refreshing our application

Now let's refresh our browser:

```bash
http://<yourHostIP>:80
```

We can see the updated color of our company naming application.

![web application 2](Local_Development_Workflow/webapp2.png)

---
## Improving the workflow with Compose

* You can also start the container with the following command:

```bash
$ docker-compose up -d
```

* This works thanks to the Compose file, `docker-compose.yml`:

```yaml
www:
  build: .
  volumes:
    - .:/src
  ports:
    - 80:9292
```

---
## Why Compose?

* Specifying all those "docker run" parameters is tedious.
* And error-prone.
* We can "encode" those parameters in a "Compose file."
* When you see a `docker-compose.yml` file, you know that you can use `docker-compose up`.
* Compose can also deal with complex, multi-container apps.
  <br/>(More on this later.)

---
## Workflow explained

We can see a simple workflow:

1. Build an image containing our development environment.

    (Rails, Django...)

2. Start a container from that image.

    Use the `-v` flag to mount source code inside the container.

3. Edit source code outside the containers, using regular tools.

    (vim, emacs, textmate...)

4. Test application.

    (Some frameworks pick up changes automatically.

    Others require you to Ctrl-C + restart after each modification.)

5. Repeat last two steps until satisfied.

6. When done, commit+push source code changes.

    (You *are* using version control, right?)

---
class: x-extra-details

## Debugging inside the container

In 1.3, Docker introduced a feature called `docker exec`.

It allows users to run a new process in a container which is already running.

If sometimes you find yourself wishing you could SSH into a container: you can use `docker exec` instead.

You can get a shell prompt inside an existing container this way, or run an arbitrary process for automation.

---
class: extra-details

## `docker exec` example

```bash
$ # You can run ruby commands in the area the app is running and more!
$ docker exec -it <yourContainerId> bash
root@5ca27cf74c2e:/opt/namer# irb
irb(main):001:0> [0, 1, 2, 3, 4].map {|x| x ** 2}.compact
=> [0, 1, 4, 9, 16]
irb(main):002:0> exit
```

---
class: x-extra-details

## Stopping the container

Now that we're done let's stop our container.

```bash
$ docker stop <yourContainerID>
```

And remove it.

```bash
$ docker rm <yourContainerID>
```

---
## Section summary

We've learned how to:

* Share code between container and host.
* Set our working directory.
* Use a simple local development workflow.

