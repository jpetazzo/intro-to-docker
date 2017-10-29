---
class: title

# Your training Virtual Machine

![SSH terminal](ssh.jpg)
---


### Objectives

In this section, we will see how to use your training Virtual Machine.

If you are following this course as part of an official Docker training
or workshop, you have been given credentials to connect to your own
private Docker VM.

If you are following this course on your own, without access to an
official training Virtual Machine, just skip this lesson, and check
"Installing Docker" instead.
---
## Your training Virtual Machine

This section assumes that you are following this course as part of
an official Docker training or workshop, and have been given credentials
to connect to your own private Docker VM.

This VM has been created specifically for you, just before the training.

It comes pre-installed with the latest and shiniest version of Docker,
as well as some useful tools.

It will stay up and running for the whole training, but it will be destroyed
shortly after the training.


---
## Connecting to your Virtual Machine

You need an SSH client.

* On OS X, Linux, and other UNIX systems, just use `ssh`:

        ```bash
        $ ssh <login>@<ip-address>

* On Windows, if you don't have an SSH client, you can download:
  * Putty (www.putty.org)
  * Git BASH (https://git-for-windows.github.io/)
  * MobaXterm (http://moabaxterm.mobatek.net)


---
## Checking your Virtual Machine

Once logged in, make sure that you can run a basic Docker command:

    ```bash
    $ docker version
    Client:
     Version:      1.11.1
     API version:  1.23
     Go version:   go1.5.4
     Git commit:   5604cbe
     Built:        Tue Apr 26 23:38:55 2016
     OS/Arch:      linux/amd64

    Server:
     Version:      1.11.1
     API version:  1.23
     Go version:   go1.5.4
     Git commit:   5604cbe
     Built:        Tue Apr 26 23:38:55 2016
     OS/Arch:      linux/amd64

* If this doesn't work, raise your hand so that an instructor can assist you!
