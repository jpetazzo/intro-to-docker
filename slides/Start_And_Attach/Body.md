<!SLIDE>
# Background and foreground

The distinction between foreground and background containers is arbitrary.

From Docker's point of view, all containers are the same.

All containers run the same way, whether there is a client attached to them or not.

It is always possible to detach from a container, and to reattach to a container.

<!SLIDE>
# Detaching from a container

* You can detach from a container by typing `^P^Q`.
* Two conditions must be met:

  * The container must have been started *with a terminal* (`-t` option).
  * The container standard input must be connected (`-i` option).

* Another universal way to detach from a container is to kill the Docker client!

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
