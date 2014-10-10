<!SLIDE>
# Introduction to the Docker API

So far we've used Docker's command line tools to interact with it.
Docker also has a fully fledged RESTful API you can work with.

The API allows:

* To build images.
* Run containers.
* Manage containers.

<!SLIDE>
# Docker API details

The Docker API is:

* Broadly RESTful with some commands hijacking the HTTP connection for
  STDIN, STDERR, and STDOUT.
* The API binds locally to ``unix:///var/run/docker.sock`` but can also
  be bound to a network interface.
* Not authenticated by default.
* Securable with certificates.

In the examples below, we will assume that Docker has been
setup so that the API listens on port 2375, because tools
like ``curl`` can't talk to a local UNIX socket directly.

<!SLIDE>
# Testing the Docker API

Let's start by using the ``info`` endpoint to test the Docker API.

This endpoint returns basic information about our Docker host.

    @@@ Sh
    $ curl --silent -X GET http://localhost:2375/info \
      | python -mjson.tool
    {
        "Containers": 68,
        "Debug": 0,
        "Driver": "aufs",
        "DriverStatus": [
            [
                "Root Dir",
                "/var/lib/docker/aufs"
            ],
            [
                "Dirs",
                "711"
            ]
        ],
        "ExecutionDriver": "native-0.2",
        "IPv4Forwarding": 1,
        "Images": 575,
        "IndexServerAddress": "https://index.docker.io/v1/",
        "InitPath": "/usr/bin/docker",
        "InitSha1": "",
        "KernelVersion": "3.14.0-1-amd64",
        "MemoryLimit": 1,
        "NEventsListener": 0,
        "NFd": 11,
        "NGoroutines": 11,
        "OperatingSystem": "<unknown>",
        "SwapLimit": 1
    }

<!SLIDE>
# Doing ``docker run`` via the API

It is simple to do ``docker run`` with the CLI, but it is
more complex with the API. It involves multiple calls.

We will focus on *detached* containers for now (i.e.,
running in the background). Interactive containers
involve hijacking the HTTP connection. This is easily
handled with Docker client libraries, but for now, we
will use regular tools like ``curl``.

<!SLIDE>
# Container lifecycle with the API

To run a container, you must:

* Create the container. It is then stopped, but ready to go.
* Start the container.
* Optionally, you can wait for the container to exit.
* You can also retrieve the container output (logs) with the API.

Each of those operations corresponds to a specific API call.

<!SLIDE>
# "Create" vs. "Start"

The ``create`` API call creates the container, and gives us
the ID of the newly created container. The container does not
run yet, though. 

The ``start`` API call tells Docker to transition the container
from "stopped" to "running".

Those are two different calls, so you can attach to the container
before starting it, to make sure that you will not miss any output
from the container, for instance.

Some parameters (e.g. which image to use, memory limits) must be
specified with ``create``; others (e.g. ports and volumes mappings)
must be specified with ``start``.

To see the list of all parameters, check the API reference
documentation.

<!SLIDE>
# Creating a new container via the API

Let's use ``curl`` to create a simple container.

    @@@ Sh
    $ curl -X POST -H 'Content-Type: application/json' \
      http://localhost:2375/containers/create \
      -d '{
        "Cmd":["echo", "hello world"],
        "Image":"busybox"
      }'
      {"Id":"<yourContainerID>","Warnings":null}

* You can see the container ID returned by the API.
* The ``Cmd`` parameter has to be a list.

    (If you put ``echo hello world`` it will try to 
    execute a binary called ``echo hello world``.)

* You can add more parameters in the JSON structure.
* The only mandatory parameter is the ``Image`` to use.

<!SLIDE>
# Starting our new container via the API

In the previous step, the API gave you a container ID.

You will have to copy-paste that ID.

    @@@ Sh
    $ curl -X POST -H 'Content-Type: application/json' \
      http://localhost:2375/containers/<yourContainerID>/start \
      -d '{}'

No output will be shown (unless an error happens).

<!SLIDE>
# Inspecting our launched container

We can also inspect our freshly launched container.

    @@@ Sh
    $ curl --silent \
      http://localhost:2375/containers/<yourContainerID>/json |
      python -mjson.tool
    {
      "Args": [
          "hello world"
       ],
      "Config": {
        "AttachStderr": false,
        "AttachStdin": false,
        "AttachStdout": false,
        "Cmd": [
            "echo",
	    "hello world"
        ],
        . . .
    }

* It returns the same hash the ``docker inspect`` command returns.

<!SLIDE>
# Waiting for our container to exit and check its status code

Our test container will run and exit almost instantly.

But for containers running for a longer period of time,
we can call the ``wait`` endpoint.

The ``wait`` endpoint also gives the exit status of the
container.

    @@@ Sh
    $ curl --silent -X POST \
      http://localhost:2375/containers/<yourContainerID>/wait
    {"StatusCode":0}

* Note that you have to use a ``POST`` method here.
* The ``StatusCode`` of ``0`` means that the process
  exited normally, without error.

<!SLIDE>
# Viewing container output (logs)

Our container is supposed to echo ``hello world``.

Let's verify that.

    @@@ Sh
    $ curl --silent \
      http://localhost:2375/containers/<yourContainerID>/logs?stdout=1
    
    hello world

* There are other options, to select which streams to see
  (stdout and/or stderr), whether or not to show timestamps,
  and to follow the logs (like ``tail -f`` does).
* Check the API reference documentation to see all available
  options.

<!SLIDE>
# Stopping a container

We can also stop a container using the API.

    @@@ Sh
    $ curl --silent -X POST \
      http://localhost:2375/containers/<yourContainerID>/stop

* Note that you have to use a ``POST`` call here.
* If it succeeds it will return a HTTP 204 response code.

<!SLIDE>
# Working with images

We can also work with Docker images.

    @@@ Sh
    $ curl -X GET http://localhost:2375/images/json?all=0
    [
      {
        "Created": 1396291095,
        "Id": "cccdc2d2ec497e814793e8bd952ae76d5d552c8bb7ed927db54aa65579508ffd",
        "ParentId": "9cd978db300e27386baa9dd791bf6dc818f13e52235b26e95703361ec3c94dc6",
        "RepoTags": [
            "training/datavol:latest"
        ],
        "Size": 0,
        "VirtualSize": 204371253
      },
      {
        "Created": 1396117401,
        "Id": "d4faa2107ddab5b22e815759d9a345f1381562ad44d1d95235347d6b006ec713",
        "ParentId": "439aa219e271671919a52a8d5f7a8e7c2b2950c639f09ce763ac3a06c0d15c22",
        . . .
      }
    ]

* Returns a hash of all images.

<!SLIDE>
# Searching the Docker Hub for an image

We can also search the Docker Hub for specific images.

    @@@ Sh
    $ curl -X GET http://localhost:2375/images/search?term=training
    [
      {
        "description": "",
        "is_official": false,
        "is_trusted": true,
        "name": "training/namer",
        "star_count": 0
      },
      {
        "description": "",
        "is_official": false,
        "is_trusted": true,
        "name": "training/postgres",
        "star_count": 0
      }
    ]

This returns a list of images and their metadata.

<!SLIDE>
# Creating an image

We can then add one of these images to our Docker host.

    @@@ Sh
    $ curl -i -v -X POST \
      http://localhost:2375/images/create?fromImage=training/namer
      {"status":"Pulling repository training/namer"}

This will pull down the ``training/namer`` image and add it to our Docker host.

<!SLIDE>
# Section summary

We've learned how to:

* Work with the Docker API.
* Create and manage containers with the Docker API.
* Manage images with the Docker API.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Test the `info` Docker Remote API Endpoint

1. Go to the command line.

2. Use the `curl` command to test our connection to the local Docker
   daemon.

        @@@ Sh
        $ curl --silent -X GET http://localhost:2375/info \
          | python -mjson.tool

3. You should see output like:

        @@@ Sh
        {
            "Containers": 68,
            "Debug": 0,
            "Driver": "aufs",
            "DriverStatus": [
        	[
        	    "Root Dir",
        	    "/var/lib/docker/aufs"
        	],
        	[
        	    "Dirs",
        	    "711"
        	]
            ],
              . . .

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Creating a new container via the API

1. Now let's see how to create a container with the API.

        @@@ Sh
        $ curl -X POST -H 'Content-Type: application/json' \
          http://localhost:2375/containers/create \
          -d '{
            "Cmd":["echo", "hello world"],
            "Image":"busybox"
          }'

2. You should see a container ID returned.

        @@@ Sh
        {"Id":"<yourContainerID>","Warnings":null}

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Starting our new container

1. Start the container that we just created.

        @@@ Sh
        $ curl -X POST -H 'Content-Type: application/json' \
          http://localhost:2375/containers/<yourContainerID>/start \
          -d '{}'

No output will be shown, unless an error happens.

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Inspecting our launched container

1. Now inspect our freshly launched container.

        @@@ Sh
        $ curl --silent \
        http://localhost:2375/containers/<yourContainerID>/json

2. You should see similar output to the `docker inspect` command.

        @@@ Sh
        {
          "Args": [
              "hello world"
           ],
          "Config": {
            "AttachStderr": false,
            "AttachStdin": false,
            "AttachStdout": false,
            "Cmd": [
        	"echo",
        	"hello world"
            ],
            . . .
        }

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Waiting for the container to exit, and check its exit status

1. Call the ``wait`` endpoint.

        @@@ Sh
        $ curl --silent -X POST \
          http://localhost:2375/containers/<yourContainerID>/wait

2. Check the result.

        @@@ Sh
        {"StatusCode":0}

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Viewing container output

1. Call the ``logs`` endpoint, asking for the stdout stream.

        @@@ Sh
        $ curl --silent \
          http://localhost:2375/containers/<yourContainerID>/logs?stdout=1

2. You should see the result of the ``echo`` command.

        @@@ Sh
        hello world

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Working with images

1. Now lets see all the images available on the Docker host.

        @@@ Sh
        $ curl -X GET http://localhost:2375/images/json?all=0

2. You should see a hash of all images on the Docker host.

        @@@ Sh
        [
          {
            "Created": 1396291095,
            "Id": "cccdc2d2ec497e814793e8bd952ae76d5d552c8bb7ed927db54aa65579508ffd",
        "ParentId": "9cd978db300e27386baa9dd791bf6dc818f13e52235b26e95703361ec3c94dc6",
        "RepoTags": [
            "training/datavol:latest"
        ],
        "Size": 0,
        "VirtualSize": 204371253
          },
        ]

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Searching the Docker Hub for an image

1. Now initiate a search for a specific image.

        @@@ Sh
        $ curl -X GET http://localhost:2375/images/search?term=training


2. You should see a hash of images.

        @@@ Sh
        [
          {
            "description": "",
            "is_official": false,
            "is_trusted": true,
            "name": "training/namer",
            "star_count": 0
          },
          . . .
        ]

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Creating an image

1. Now download one of these images.

        @@@ Sh
        $ curl -i -v -X POST \
        http://localhost:2375/images/create?fromImage=training/namer

2. You should see a status indicating it is retrieving the image.

        @@@ Sh
        {"status":"Pulling repository training/namer"}

