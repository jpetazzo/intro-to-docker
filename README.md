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

There are AMI instances in US West 2.

| Region     | AMI          |
|------------|--------------|
| us-west-2  | ami-a180f291 |

## Launching images

Use AWS Command line tools.

Install them via `pip`.

    $ pip install awscli

Then use the `aws` command.

    $ aws ec2 run-instances --image-id ami-5d160a34 --instance-type t1.micro --count #ofinstancesneeded

#### Getting list of IP addresses

    $ aws ec2 describe-instances | grep -E -o "\d+\.\d+\.\d+\.\d+" | grep -v '^10\.'

## Generating PDFs

You can either `make pdf`, or follow those instructions.

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


