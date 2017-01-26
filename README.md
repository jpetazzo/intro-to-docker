# Intro to Docker

This repository contains training materials for basic Docker training. 


## History and relation to other training materials

This course was originally written by Aaron Huslage, James Turnbull,
Jérôme Petazzoni, and Nathan LeClaire (all employees of Docker Inc. at
that time). It was used for a while by Docker Inc. and its authorized
training partners as the "Docker Fundamentals" course. It was a 2-day,
instructor-led training, covering much more ground than the current
repository.

Over time, the original "Docker Fundamentals" course was split into
additional modules for various audiences, and it stopped being maintained
by Docker Inc. A few people continued to use the first half of the course
to deliver Docker workshops for underrepresentend minorities in tech, e.g.
with [GoBridge](https://blog.golangbridge.org/gobridge-is-organizing-a-docker-workshop-7b8c1f5f6060#.arg46bwer),
[Women Who Go](https://www.meetup.com/Women-Who-Go-Berlin/events/230021596/),
[Girl Develop It](https://www.meetup.com/girldevelopit/events/233729751/), etc.

The first half of the content continued to be updated by individual
contributors to include new features of Docker, while the second half
was removed since it wasn't useful anymore in this context.

Docker Inc. agreed to make the current version of the repository public.
This will allow anyone to use this content for basic Docker courses.

**Please note that this material is not "official" in any way.** It derives
from material that was official in 2014, but that's pretty much it!

Also note that this material was designed primarily for instructor-led
training. If you want to learn Docker on your own, Docker Inc. has
[self-paced learning online materials](
http://training.docker.com/category/self-paced-online) as well as
tons of [tutorials and hands on labs](https://github.com/docker/labs).

Finally, keep in mind that this is an intro-level course. If you
want to tackle more advanced topics, we invite you to check
[instructor-led training sessions](http://training.docker.com/instructor-led-training)
offered by Docker Inc. and its training partners.

Thank you!


## Course format

It uses Puppetlabs' fork of [showoff]. Showoff is a program that takes:

- a JSON file, which acts as a table of contents, referencing ...
- ... a number of Markdown files, which are the content of the course.

Showoff will be installed in a container; so you need Docker to run this!


## How to use it (editor mode)

Run `make dev`. Point your browser to http://localhost:9090/ (or to
your Docker machine IP address, on port 9090)).

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

The materials assume that each attendee receives a cloud instance,
pre-installed to have the latest version of Docker and a few other
helpful things installed.

These instances can be created automatically using scripts located
in another repository, [jpetazzo/orchestration-workshop/prepare-vms](
https://github.com/jpetazzo/orchestration-workshop/tree/master/prepare-vms).
This will require an AWS account with a credit card.

You can also do some minor adaptations and use [Play-With-Docker](
http://play-with-docker.com/) instead.


## Other tools

The [tools](tools) directory has a bunch of various useful scripts.


## Manual operation

If you want to run showoff or print PDFs locally, check
[PAINFUL.md](PAINFUL.md) for instructions.


## Feedback

Please report problems, typos, etc. by opening GitHub issues on this
repository. The unofficial maintainer of this repo is @jpetazzo.


[showoff]: https://github.com/puppetlabs/showoff


