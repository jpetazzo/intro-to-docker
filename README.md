Docker-Fundamentals
=======================

Repository for Docker Fundamentals course materials

https://www.docker.com/whatisdocker/

# Instructor Guide for Docker Fundamentals 

## Installation (Slide Deck)

### Containerized Version

In the project's repository root, run:

    $ make dev

The stack needed to run the slide deck will be installed and served inside of a
Docker container, which will then be available at host port 9090.

`make dev` gives you the "development" version of the slide deck, complete with
the source mounted into the container via a volume for easy editing.

When you are actually delivering the slide deck to a class of students, do a
`git checkout` of the SHA version that the books are tagged with (if there
aren't any physical or electronic copies distributed then you won't have to
worry about this) and then run :

    $ make showoff

This will ensure that your slide deck is exactly consistent with the materials
that the students have for reference.

### Manual Version

You'll need the [Puppet Labs fork of
Showoff](https://github.com/puppetlabs/showoff/).

    $ git clone https://github.com/puppetlabs/showoff.git
    $ cd showoff
    $ gem build showoff.gemspec
    $ sudo gem install ./showoff-*.gem

Showoff is tested with Ruby 1.8.7, 1.9.3, and 2.0. It should install
cleanly on these versions.

To run the training:

    $ showoff serve

You should be able to see the slides at:

    http://localhost:9090

You will be able to see the exercises at:

    http://localhost:9090/supplemental/exercises

The user name is ``docker`` and the password is ``maersk``.

## Training VMs

When performing a class, each attendee receives an Amazon EC2 instance which has
been pre-provisioned to have the latest version of Docker and a few other
helpful things installed.

To spin up and down these instances, we use the script located at
`tools/trainctl`.

### Using `trainctl`

To use `trainctl`, first you must set the proper AWS environment variables to
authenticate your IAM user with the AWS API:

```
export AWS_ACCESS_KEY=xxxxxxxxxxxxxxx
export AWS_SECRET_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

You can create these access keys through your user in the IAM section of the AWS
console.

Next, follow the steps below to either run `trainctl` in a container or natively
on your host computer.

#### Using `trainctl` in a container

The easiest way to use `trainctl` is in a container.  That way, you don't have
to install Java and the AWS tools yourself.

To do so, just make sure you set the aforementioned environment variables and
then use the `container_trainctl.sh` script just like you would use `trainctl`
regularly.

To start 5 VMs:

```console
$ ./container_trainctl.sh start 5
```

You will get back an output which looks like this:

```console
Building image needed to execute trainctl script...
Sending build context to Docker daemon  12.8 kB
Sending build context to Docker daemon
Step 0 : FROM training/ec2tools:1.7.3.0
 ---> f400883b006b
Step 1 : COPY . /tools
 ---> 35b0f73a4999
Removing intermediate container f38864d0b8df
Step 2 : WORKDIR /tools
 ---> Running in 3615e319e87e
 ---> ef012ecc0243
Removing intermediate container 3615e319e87e
Step 3 : ENTRYPOINT ./trainctl
 ---> Running in 17d02bd675b1
 ---> 04d4d824f844
Removing intermediate container 17d02bd675b1
Successfully built 04d4d824f844
RESERVATION     r-0abe6900      437775732836
TAG     instance        i-c81d24c2      Name    2015-02-05-01-05-nathanleclaire
TAG     instance        i-ce1d24c4      Name    2015-02-05-01-05-nathanleclaire
TAG     instance        i-cf1d24c5      Name    2015-02-05-01-05-nathanleclaire
TAG     instance        i-cc1d24c6      Name    2015-02-05-01-05-nathanleclaire
TAG     instance        i-cd1d24c7      Name    2015-02-05-01-05-nathanleclaire
NICASSOCIATION  54.68.165.140   amazon  172.31.44.195
NICASSOCIATION  54.149.218.113  amazon  172.31.44.193
NICASSOCIATION  54.149.200.26   amazon  172.31.44.194
NICASSOCIATION  54.149.19.36    amazon  172.31.44.196
NICASSOCIATION  54.149.186.166  amazon  172.31.44.197
Successfully created 5 instances with tag:
2015-02-05-01-05-nathanleclaire
```

There are a few things to note about this output and the properties that the
created instances will have.

1. The instances can be accessed via SSH on their public IP address (the one
   between `NICASSOCIATION` and `amazon` in the above output).  The username is
   `docker` and the password is `training`.
2. Make sure to take note of the tag the instances were created with, as this
   will be used later when you want to destroy them.
3. All instances will be brought up with Docker and a few other things such as
   jq for JSON pretty printing, but the provisioning may take a few minutes.
4. Most ports are open by default, so if you forward a port to, say, `49153` on
   the host from a container, it will be accessible from the outside world.

To stop (destroy) the instances you have created, use the `stop` command with
the tag, for instance:

```console
$ ./container_trainctl.sh stop 2015-02-05-01-05-nathanleclaire
```

`start` and `stop` are all that you need to know to run a training.  Just start
them a few minutes before the training begins, and stop them when the training
is over.

There are a few more "verbs" available and you can learn about them by reading
the source code if you are interested.


#### Using `trainctl` manually

`trainctl` can also be used manually, of course.  You must ensure that the AWS
Java CLI tools are installed and configured correctly on your system, and that
the environment variables mentioned above are set.  To invoke, just run

```console
$ ./trainctl [verb]
```

## Generating PDFs

The following instructions tell you how to generate the PDF version of the slide
deck and exercises for printing or sending to students.

### Containerized Version

Run `make pdf` in the project repository's root.  The container will spit out
`DockerSlides.pdf` and `DockerExercises.pdf` in the working directory.  These
PDFs will be automatically tagged with the git SHA at HEAD as a "version", so
that they can be distinguished down the line.

### Manual Version

1. Install PrinceXML - http://www.princexml.com/download/
2. Launch Showoff - `showoff server`
3. Browse to the /print URLs.

        http://localhost:9090/print
        http://localhost:9090/supplemental/exercises/print

4. Use Prince to product the PDFs.

        $ prince http://localhost:9090/print -o DockerSlides.pdf
        $ prince http://localhost:9090/supplemental/exercises/print -o DockerExercises.pdf

## Feedback

Feedback: [education@docker.com](mailto:education@docker.com)
