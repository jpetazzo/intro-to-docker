
class: title

# Advanced Dockerfiles

![construction](Dockerfile_Reference/construction.jpg)

---

## Objectives

We have seen simple Dockerfiles to illustrate how Docker build
container images. In this chapter, we will see:

* The syntax and keywords that can be used in Dockerfiles.
* Tips and tricks to write better Dockerfiles.

---

## `Dockerfile` usage summary

* `Dockerfile` instructions are executed in order.
* Each instruction creates a new layer in the image.
* Instructions are cached. If no changes are detected then the
  instruction is skipped and the cached layer used.
* The `FROM` instruction MUST be the first non-comment instruction.
* Lines starting with `#` are treated as comments.
* You can only have one `CMD` and one `ENTRYPOINT` instruction in a `Dockerfile`.

---

## The `FROM` instruction

* Specifies the source image to build this image.
* Must be the first instruction in the `Dockerfile`, except for comments.

---

## The `FROM` instruction
Can specify a base image:

```dockerfile
FROM ubuntu
```

An image tagged with a specific version:

```dockerfile
FROM ubuntu:12.04
```

A user image:

```dockerfile
FROM training/sinatra
```

Or self-hosted image:

```dockerfile
FROM localhost:5000/funtoo
```

---

class: extra-details

## More about `FROM`

* The `FROM` instruction can be specified more than once to build
  multiple images.

```dockerfile
FROM ubuntu:14.04
. . .
FROM fedora:20
. . .
```

    Each `FROM` instruction marks the beginning of the build of a new image.

    The `-t` command-line parameter will only apply to the last image.

* If the build fails, existing tags are left unchanged.

* An optional version tag can be added after the name of the image.

    E.g.: `ubuntu:14.04`.

---

class: extra-details

## A use case for multiple `FROM` lines

* Integrate CI and unit tests in the build system

```dockerfile
FROM <baseimage>
RUN <install dependencies>
COPY <code>
RUN <build code>
RUN <install test dependencies>
COPY <test data sets and fixtures>
RUN <unit tests>
FROM <baseimage>
RUN <install dependencies>
COPY <vcode>
RUN <build code>
CMD, EXPOSE ...
```

* The build fails as soon as an instructions fails
* If `RUN <unit tests>` fails, the build doesn't produce an image
* If it succeeds, it produces a clean image (without test libraries and data)

---

## The `MAINTAINER` instruction

The `MAINTAINER` instruction tells you who wrote the `Dockerfile`.

```dockerfile
MAINTAINER Docker Education Team <education@docker.com>
```

It's optional but recommended.

---

## The `RUN` instruction

The `RUN` instruction can be specified in two ways.

With shell wrapping, which runs the specified command inside a shell,
with `/bin/sh -c`:

```dockerfile
RUN apt-get update
```

Or using the `exec` method, which avoids shell string expansion, and
allows execution in images that don't have `/bin/sh`:

```dockerfile
RUN [ "apt-get", "update" ]
```

---

## More about the `RUN` instruction

`RUN` will do the following:

* Execute a command.
* Record changes made to the filesystem.
* Work great to install libraries, packages, and various files.

`RUN` will NOT do the following:

* Record state of *processes*.
* Automatically start daemons.

If you want to start something automatically when the container runs,
you should use `CMD` and/or `ENTRYPOINT`.

---

## Collapsing layers

It is possible to execute multiple commands in a single step:

```dockerfile
RUN apt-get update && apt-get install -y wget && apt-get clean
```

It is also possible to break a command onto multiple lines:

It is possible to execute multiple commands in a single step:

```dockerfile
RUN apt-get update \
 && apt-get install -y wget \
 && apt-get clean
```

---

## The `EXPOSE` instruction

The `EXPOSE` instruction tells Docker what ports are to be published
in this image.

```dockerfile
EXPOSE 8080
EXPOSE 80 443
EXPOSE 53/tcp 53/udp
```

* All ports are private by default.
* The `Dockerfile` doesn't control if a port is publicly available.
* When you `docker run -p <port> ...`, that port becomes public.

    (Even if it was not declared with `EXPOSE`.)

* When you `docker run -P ...` (without port number), all ports
  declared with `EXPOSE` become public.

A *public port* is reachable from other containers and from outside the host.

A *private port* is not reachable from outside.

---

## The `COPY` instruction

The `COPY` instruction adds files and content from your host into the
image.

```dockerfile
COPY . /src
```

This will add the contents of the *build context* (the directory
passed as an argument to `docker build`) to the directory `/src`
in the container.

Note: you can only reference files and directories *inside* the
build context. Absolute paths are taken as being anchored to
the build context, so the two following lines are equivalent:

```dockerfile
COPY . /src
COPY / /src
```

Attempts to use `..` to get out of the build context will be
detected and blocked with Docker, and the build will fail.

Otherwise, a `Dockerfile` could succeed on host A, but fail on host B.

---

## `ADD`

`ADD` works almost like `COPY`, but has a few extra features.

`ADD` can get remote files:

```dockerfile
ADD http://www.example.com/webapp.jar /opt/
```

This would download the `webapp.jar` file and place it in the `/opt`
directory.

`ADD` will automatically unpack zip files and tar archives:

```dockerfile
ADD ./assets.zip /var/www/htdocs/assets/
```

This would unpack `assets.zip` into `/var/www/htdocs/assets`.

*However,* `ADD` will not automatically unpack remote archives.

---

## `ADD`, `COPY`, and the build cache

* For most Dockerfiles instructions, Docker only checks
  if the line in the Dockerfile has changed.
* For `ADD` and `COPY`, Docker also checks if the files
  to be added to the container have been changed.
* `ADD` always need to download the remote file before
  it can check if it has been changed. (It cannot use,
  e.g., ETags or If-Modified-Since headers.)

---

## `VOLUME`

The `VOLUME` instruction tells Docker that a specific directory
should be a *volume*.

```dockerfile
VOLUME /var/lib/mysql
```

Filesystem access in volumes bypasses the copy-on-write layer,
offering native performance to I/O done in those directories.

Volumes can be attached to multiple containers, allowing to
"port" data over from a container to another, e.g. to
upgrade a database to a newer version.

It is possible to start a container in "read-only" mode.
The container filesystem will be made read-only, but volumes
can still have read/write access if necessary.

---

## The `WORKDIR` instruction

The `WORKDIR` instruction sets the working directory for subsequent
instructions.

It also affects `CMD` and `ENTRYPOINT`, since it sets the working
directory used when starting the container.
   
```dockerfile
WORKDIR /src
```

You can specify `WORKDIR` again to change the working directory for
further operations.

---

## The `ENV` instruction

The `ENV` instruction specifies environment variables that should be
set in any container launched from the image.

```dockerfile
ENV WEBAPP_PORT 8080
```

This will result in an environment variable being created in any
containers created from this image of

```bash
WEBAPP_PORT=8080
```

You can also specify environment variables when you use `docker run`.

```bash
$ docker run -e WEBAPP_PORT=8000 -e WEBAPP_HOST=www.example.com ...
```

---

## The `USER` instruction

The `USER` instruction sets the user name or UID to use when running
the image.

It can be used multiple times to change back to root or to another user.

---

## The `CMD` instruction

The `CMD` instruction is a default command run when a container is
launched from the image.

```dockerfile
CMD [ "nginx", "-g", "daemon off;" ]
```

Means we don't need to specify `nginx -g "daemon off;"` when running the
container.

Instead of:

```bash
$ docker run <dockerhubUsername>/web_image nginx -g "daemon off;"
```

We can just do:

```bash
$ docker run <dockerhubUsername>/web_image
```

---

## More about the `CMD` instruction

Just like `RUN`, the `CMD` instruction comes in two forms.
The first executes in a shell:

```dockerfile
CMD nginx -g "daemon off;"
```

The second executes directly, without shell processing:

```dockerfile
CMD [ "nginx", "-g", "daemon off;" ]
```

---

class: extra-details

## Overriding the `CMD` instruction

The `CMD` can be overridden when you run a container.

```bash
$ docker run -it <dockerhubUsername>/web_image bash
```

Will run `bash` instead of `nginx -g "daemon off;"`.

---

## The `ENTRYPOINT` instruction

The `ENTRYPOINT` instruction is like the `CMD` instruction,
but arguments given on the command line are *appended* to the
entry point.

Note: you have to use the "exec" syntax (`[ "..." ]`).

```dockerfile
ENTRYPOINT [ "/bin/ls" ]
```

If we were to run:

```bash
$ docker run training/ls -l
```

Instead of trying to run `-l`, the container will run `/bin/ls -l`.

---

class: extra-details

## Overriding the `ENTRYPOINT` instruction

The entry point can be overriden as well.

```bash
$ docker run -it training/ls
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
$ docker run -it --entrypoint bash training/ls
root@d902fb7b1fc7:/#
```

---

## How `CMD` and `ENTRYPOINT` interact

The `CMD` and `ENTRYPOINT` instructions work best when used
together.

```dockerfile
ENTRYPOINT [ "nginx" ]
CMD [ "-g", "daemon off;" ]
```

The `ENTRYPOINT` specifies the command to be run and the `CMD`
specifies its options. On the command line we can then potentially
override the options when needed.

```bash
$ docker run -d <dockerhubUsername>/web_image -t
```

This will override the options `CMD` provided with new flags.

---

## Advanced Dockerfile instructions

* ONBUILD lets you stash instructions that will be executed
  when this image is used as a base for another one.
* LABEL adds arbitrary metadata to the image.
* ARG defines build-time variables (optional or mandatory).
* STOPSIGNAL sets the signal for `docker stop` (`TERM` by default).
* HEALTHCHECK defines a command assessing the status of the container.
* SHELL sets the default program to use for string-syntax RUN, CMD, etc.

---

class: extra-details

## The `ONBUILD` instruction

The `ONBUILD` instruction is a trigger. It sets instructions that will
be executed when another image is built from the image being build.

This is useful for building images which will be used as a base
to build other images.

```dockerfile
ONBUILD COPY . /src
```

* You can't chain `ONBUILD` instructions with `ONBUILD`.
* `ONBUILD` can't be used to trigger `FROM` and `MAINTAINER`
  instructions.

---

## Building an efficient `Dockerfile` 

* Each line in a `Dockerfile` creates a new layer.
* Build your `Dockerfile` to take advantage of Docker's caching system.
* Combine multiple similar commands into one by using `&&` to continue commands and `\\` to wrap lines.
* `COPY` dependency lists (`package.json`, `requirements.txt`, etc.) by themselves to avoid reinstalling unchanged dependencies every time.

---

## Example "bad" `Dockerfile`

The dependencies are reinstalled every time, because the build system does not know if `requirements.txt` has been updated.

```bash
FROM python
MAINTAINER Docker Education Team <education@docker.com>
COPY . /src/
WORKDIR /src
RUN pip install -qr requirements.txt
EXPOSE 5000
CMD ["python", "app.py"]
```

---

## Fixed `Dockerfile`

Adding the dependencies as a separate step means that Docker can cache more efficiently and only install them when `requirements.txt` changes.

        ```bash
        FROM python
        MAINTAINER Docker Education Team <education@docker.com>
        COPY ./requirements.txt /tmp/requirements.txt
        RUN pip install -qr /tmp/requirements.txt
        COPY . /src/
        WORKDIR /src
        EXPOSE 5000
        CMD ["python", "app.py"]
