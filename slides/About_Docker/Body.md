<!SLIDE>
# OK... Why the buzz around containers?

* The software industry has changed.
* Before:
  * monolithic applications
  * long development cycles
  * single environment
  * slowly scaling up
* Now:
  * decoupled services
  * fast, iterative improvements
  * multiple environments
  * quickly scaling out

<!SLIDE>
# Deployment becomes very complex

* Many different stacks:
  * languages
  * frameworks
  * databases
* Many different targets:
  * individual development environments
  * pre-production, QA, staging...
  * production: on prem, cloud, hybrid

<!SLIDE>
# The deployment problem

![problem](problem.png)

<!SLIDE>
# The Matrix from Hell

![matrix](matrix.png)

<!SLIDE>
# An inspiration and some ancient history!

![history](history.png)

<!SLIDE>
# Intermodal shipping containers

![shipping](shipping.png)

<!SLIDE>
# This spawned a Shipping Container Ecosystem!

![shipeco](shipeco.png)

<!SLIDE>
# A shipping container system for applications

![shipapp](appcont.png)

<!SLIDE>
# Eliminate the matrix from Hell

![elimatrix](elimatrix.png)

<!SLIDE>
# A little bit of history

<!SLIDE>
# First experimentations

* [IBM VM/370 (1972)](https://en.wikipedia.org/wiki/VM_(operating_system))
* [Linux VServers (2001)](http://www.solucorp.qc.ca/changes.hc?projet=vserver)
* [Solaris Containers (2004)](https://en.wikipedia.org/wiki/Solaris_Containers)
* [FreeBSD jails (1999)](https://www.freebsd.org/cgi/man.cgi?query=jail&sektion=8&manpath=FreeBSD+4.0-RELEASE)

Containers have been around for a *very long time*.

Why are they trending now?

What does Docker bring to the table?

<!SLIDE>
# VPS-olithic period (until 2007-2008)

<!SLIDE>
# Containers = cheaper than VMs

![lightcont](lightcont.png)

* Users: hosting providers.
* Highly specialized audience with strong ops culture.

<!SLIDE>
# PaaS-olithic period (2008-2013)

<!SLIDE>
# Containers = easier than VMs

![heroku 2007](heroku-first-homepage.png)

* I can't speak for Heroku, but containers were (one of) dotCloud's secret weapon

<!SLIDE>
# Docker early days (2013-2014)

<!SLIDE>
# First users of Docker

* PAAS builders (Flynn, Dokku, Tsuru, Deis...)
* PAAS users (those big enough to justify building their own)
* CI platforms
* developers, developers, developers, developers

<!SLIDE>
# Positive feedback loop

* In 2013, the technology under containers (cgroups, namespaces, copy-on-write storage...)
  had many blind spots.
* The growing popularity of Docker and containers exposed many bugs.
* As a result, those bugs were fixed, resulting in better stability for containers.
* Any decent hosting/cloud provider can run containers today.
* Containers become a great tool to deploy/move workloads to/from on-prem/cloud.

<!SLIDE>
# Maturity

<!SLIDE>
# Docker becomes a platform

* Docker Engine reaches 1.0
* Launch of Compose, Machine, Swarm ...
* Docker Inc. launches commercial offers
* Other container engines appear
* Standards like OCI, CNCF appear
* Existing systems like Mesos and Cloud Foundry add Docker support

<!SLIDE>
# What did Docker bring to the table?

<!SLIDE>
# Formats and APIs, before Docker

* No standardized exchange format.
  <br/>(No, a rootfs tarball is *not* a format!)
* Containers are hard to use for developers.
  <br/>(Where's the equivalent of `docker run debian`?)
* As a result, they are *hidden* from the end users.
* No re-usable components, APIs, tools.
  <br/>(At best: VM abstractions, e.g. libvirt.)

Analogy: 

* Shipping containers are not just steel boxes.
* They are steel boxes that are a standard size,
  <br/>with the same hooks and holes.

<!SLIDE>
# Formats and APIs, after Docker

* Standardize the container format, because containers were not portable.
* Make containers easy to use for developers.
* Emphasis on re-usable components, APIs, ecosystem of standard tools.
* Improvement over ad-hoc, in-house, specific tools.

<!SLIDE>
# Shipping, before Docker

* Ship packages: deb, rpm, gem, jar...
* Dependency hell.
* "Works on my machine."
* Base deployment often done from scratch (debootstrap...) and unreliable.

<!SLIDE>
# Shipping, after Docker

* Ship container images with all their dependencies.
* Break image into layers.
* Only ship layers that have changed.
* Save disk, network, memory usage.

<!SLIDE>
# Example

Layers:

* CentOS
* JRE
* Tomcat
* Dependencies
* Application JAR
* Configuration

<!SLIDE>
# Technical & cultural revolution: separation of concerns

![sepcon](sepcon.png)

<!SLIDE>
# Docker today

<!SLIDE>
# Non-exhaustive list of "Docker wins"

* Describe the build of your app with a Dockerfile.
* Describe your stack with a Compose file.
* On-board developers and contributors in minutes:

          @@@
          git clone ...
          docker-compose up

* Consolidate a cluster of Docker Engines with Swarm.
* Scale, add load balancers, replication ... without changing your app.
* Use the same containers (bit-for-bit) at every stage: dev, CI, QA, prod ...

<!SLIDE>
# Docker (the open source project)

<!SLIDE>
# The origins of the Docker Project

* dotCloud was operating a PaaS, using a custom container engine.
* This engine was based on OpenVZ (and later, LXC) and AUFS.
* It started (circa 2008) as a single Python script.
* By 2012, the engine had multiple (~10) Python components.
  <br/>(and ~100 other micro-services!)
* End of 2012, dotCloud refactors this container engine.
* The codename for this project is "Docker."

<!SLIDE>
# First public release

* March 2013, PyCon, Santa Clara:
  <br/>"Docker" is shown to a public audience for the first time.
* It is released with an open source license.
* Very positive reactions and feedback!
* The dotCloud team progressively shifts to Docker development.
* The same year, dotCloud changes name to Docker.
* In 2014, the PaaS activity is sold.

<!SLIDE>
# The Docker Project

* The initial container engine is now known as "Docker Engine."
* Other tools have been added:
  * Docker Compose (formerly "Fig")
  * Docker Machine
  * Docker Swarm
  * Kitematic
  * Docker Cloud (formerly "Tutum")

<!SLIDE>
# Docker Inc. (the company)

<!SLIDE>
# About Docker Inc.

* Founded in 2009.
* Formerly dotCloud Inc.
* Primary sponsor of the Docker Project.
  * Hires maintainers and contributors.
  * Provides infrastructure for the project.
  * Runs the Docker Hub.
* HQ in San Francisco.
* Backed by more than 100M in venture capital.

<!SLIDE>
# How does Docker Inc. make money?

* SAAS
  * Docker Hub (per private repo)
  * Docker Cloud (per node)
* Subscription
  * on-premise stack
  * DTR (Docker Trusted Registry)
  * UCP (Universal Control Plane)
  * CS (Commercially Supported Engine)
* Support
* Training and professional services

