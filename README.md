# Docker-Fundamentals

This repository containes the course material that we use for the
"Docker Training" (sometimes also called "Introduction to Docker",
"Docker Fundamentals", or the "Introduction to Docker Training Course").

It uses Puppetlabs' fork of [showoff]. Showoff is a program that takes:

- a JSON file, which acts as a table of contents, referencing ...
- ... a number of Markdown files, which are the content of the course.

Showoff will be installed in a container; so you need Docker to run this!

## How to use it (editor mode)

Run `make dev`. Point your browser to http://localhost:9090/ or
to your boot2docker machine on port 9090.

The slides will be bind-mounted into the container, so you can
edit them locally and showoff will (should) pickup your changes.


## How to use it (presenter mode)

When delivering a training: if the students have printed material,
the cover of the books should indicate the hash used to build the
materials. Checkout that version, then run `make release`,
and point your browser just like before.

If you don't use printed materials, you can checkout master, of course.


## How to use it (generating PDF)

`make release` (preferably!) or `make dev` (if you're tweaking things
and don't want to commit each time...) then `make pdf`.

The PDF files will be created in the current directory. Look for
`DockerSlides.pdf` and `DockerExercises.pdf`. They should be tagged
with the git hash corresponding to their source revision.


## Training VMs

When performing a class, each attendee receives a cloud intance,
pre-installed to have the latest version of Docker and a few other
helpful things installed.

To spin up and down these instances, we use the script located at
`tools/trainctl`. Look in [tools/README.md](tools/README.md) for details.


## Manual operation

Check [PAINFUL.md](PAINFUL.md) if you want to run showoff or print PDFs locally,
without container (you evil you).


## Feedback

Feedback: [education@docker.com](mailto:education@docker.com)


[showoff]: https://github.com/puppetlabs/showoff


