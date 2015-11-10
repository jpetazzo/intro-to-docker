<!SLIDE>
# Build some C code

We want to build a container that compiles a basic "Hello world" program in C.

Here is the program, `hello.c`:

    @@@ Sh
    int main () {
      puts("Hello, world!");
      return 0;
    }

Let's create a new directory, and put this file in there.

Then we will write the Dockerfile.

<!SLIDE>
# The Dockerfile

On Debian and Ubuntu, the package `build-essential` will get us a compiler.

When installing it, don't forget to specify the `-y` flag, otherwise the build will fail (since the build cannot be interactive).

Then we will use `COPY` to place the source file into the container.

    @@@ Sh
    FROM ubuntu
    RUN apt-get update
    RUN apt-get install -y build-essential
    COPY hello.c /
    RUN make hello
    CMD /hello

Create this Dockerfile.

<!SLIDE>
# Testing our C program

* Create `hello.c` and `Dockerfile` in the same direcotry.
* Run `docker build -t hello .` in this directory.
* Run `docker run hello`, you should see `Hello, world!`.

Success!

<!SLIDE>
# `COPY` and the build cache

* Run the build again.
* Now, modify `hello.c` and run the build again.
* Docker can cache steps involving `COPY`.
* Those steps will not be executed again if the files haven't been changed.

<!SLIDE>
# Details

* You can `COPY` whole directories recursively.
* Older Dockerfiles also have the `ADD` instruction.
  <br/>It is similar but can automatically extract archives.
* If we really wanted to compile C code in a compiler, we would:

  * Place it in a different directory, with the `WORKDIR` instruction.
  * Even better, use the `gcc` official image.
