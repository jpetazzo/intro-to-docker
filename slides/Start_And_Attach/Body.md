<!SLIDE>
# Background and foreground

The distinction between foreground and background containers is arbitrary.

From Docker's point of view, all containers are the same.

All containers run the same way, whether there is a client attached to them or not.

It is always possible to detach from a container, and to reattach to a container.

Analogy: attaching to a container is like plugging a keyboard and screen to a physical server.

<!SLIDE>
# Detaching from a container

* If you have started an *interactive* container (with option `-it`),
  <br/>you can detach from it.
* The "detach" sequence is `^P^Q`.
* Otherwise you can detach by killing the Docker client.
  <br/>(But not by hitting `^C`, as this would deliver `SIGINT`
  to the container.)

What does `-it` stand for?

* `-t` means "allocate a terminal."
* `-i` means "connect stdin to the terminal."

<!SLIDE printonly>
# Specifying a custom detach sequence

* You don't like `^P^Q`? No problem!
* You can change the sequence with `docker run --detach-keys`.
* This can also be passed as a global option to the engine.

Start a container with a custom detach command:

    @@@ Sh
    $ docker run -ti --detach-keys ctrl-x,x jpetazzo/clock

Detach by hitting `^X x`. (This is ctrl-x then x, not ctrl-x twice!)

Check that our container is still running:

    @@@ Sh
    $ docker ps -l

<!SLIDE printonly>
# Attaching to a container

You can attach to a container:

    @@@ Sh
    $ docker attach <containerID>

* The container must be running.
* There *can* be multiple clients attached to the same container.
* If you don't specify `--detach-keys` when attaching, it defaults back to `^P^Q`.

Try it on our previous container:

    @@@ Sh
    $ docker attach $(docker ps -lq)

Check that `^X x` doesn't work, but `^P ^Q` does.

<!SLIDE>
# Detaching from non-interactive containers

* **Warning:** if the container was started without `-it`...

  * You won't be able to detach with `^P^Q`.
  * If you hit `^C`, the signal will be proxied to the container.

* Remember: you can always detach by killing the Docker client.

<!SLIDE>
# Checking container output

* Use `docker attach` if you intend to send input to the container.
* If you just want to see the output of a container, use `docker logs`.

        @@@ Sh
        $ docker logs --tail 1 --follow <containerID>

<!SLIDE>
# Restarting a container

When a container has exited, it is in stopped state.

It can then be restarted with the `start` command.

     @@@ Sh
     $ docker start <yourContainerID>

The container will be restarted using the same options you launched it
with.

You can re-attach to it if you want to interact with it:

    @@@ Sh
    $ docker attach <yourContainerID>

Use `docker ps -a` to identify the container ID of a previous `jpetazzo/clock` container,
and try those commands.

<!SLIDE>
# Attaching to a REPL

* REPL = Read Eval Print Loop
* Shells, interpreters, TUI ...
* Symptom: you `docker attach`, and see nothing
* The REPL doesn't know that you just attached, and doesn't print anything
* Try hitting `^L` or `Enter`

<!SLIDE printonly>
# SIGWINCH

* When you `docker attach`, the Docker Engine sends a couple of SIGWINCH signals to the container.
* SIGWINCH = WINdow CHange; indicates a change in window size.
* This will cause some CLI and TUI programs to redraw the screen.
* But not all of them.
