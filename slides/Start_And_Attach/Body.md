<!SLIDE>
# Background and foreground

The distinction between foreground and background containers is arbitrary.

From Docker's point of view, all containers are the same.

All containers run the same way, whether there is a client attached to them or not.

It is always possible to detach from a container, and to reattach to a container.

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

<!SLIDE>
# Attaching to a container

You can attach to a container:

    @@@ Sh
    $ docker attach <containerID>

* The container must be running.
* There *can* be multiple clients attached to the same container.
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

You can re-attach to it if you want to interact with it.
