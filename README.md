Docker-Fundamentals
=======================

Repository for Docker Fundamentals course materials

http://www.slideshare.net/dotCloud/why-docker

# Instructor Guide for Docker Fundamentals 

## Installation

You'll need the [Puppet Labs fork of
Showoff](https://github.com/puppetlabs/showoff/).

    $ git clone https://github.com/puppetlabs/showoff.git
    $ cd showoff
    $ gem build showoff.gemspec
    $ sudo gem install ./showoff-*.gem

Showoff is tested with Ruby 1.8.7, 1.9.3, and 2.0. It should install
cleanly on these versions.

## Running the training

    $ showoff serve

You should be able to see the slides at:

    http://localhost:9090

You should be able to see the exercises at:

    http://localhost:9090/supplemental/exercises

The user name is ``docker`` and the password is ``maersk``.

## Training images

The training is based on using Amazon EC2 instances.

There are AMI instances in US East and US West 1.

| Region     | AMI          |
|------------|--------------|
| us-east-1  | ami-5d160a34 |
| us-west-1  | nil          |

## Launching images

We can launch EC2 instances with ``knife``.

Install ``knife-ec2``

    $ sudo gem install knife-ec2 --no-ri --no-rdoc

Then use the ``knife`` binary to launch:

    $ knife ec2 server create -I ami-5d160a34 --flavor t1.micro \
    -S james -x docker -P training --template-file scripts/ec2.erb

## Feedback

Feedback: [education@docker.com](mailto:education@docker.com)


