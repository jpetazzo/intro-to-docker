# Tools

Hopefully useful tools for the training material and associated course.


## trainctl

Little tool to start/stop training VMs.

It uses `cloudinit.sh` as a cloudinit payload (i.e. script that runs
when the instance boots).

To use `trainctl`, first you must set the proper AWS environment variables to
authenticate your IAM user with the AWS API:

```
export AWS_ACCESS_KEY=xxxxxxxxxxxxxxx
export AWS_SECRET_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```


### Starting training VMs

Start 10 VMs: `trainctl start 10`

This will output, at the very end, the tag for those instances,
e.g. `2014-12-24-23-58-jpetazzo`. This tag can be used to further
manipulate those instances.

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


### Getting IP address list for training VMs

You can do `trainctl ips 2014-12-24-23-58-jpetazzo` to see the list of
IP addresses.


### Seeing all VMs

You can do `trainctl list` to see all instances with tags.


### Destroying VMs after the training

Just run `trainctl stop 2014-12-24-23-58-jpetazzo` to destroy those instances.


### Opening security group

Last but not least, `trainctl opensg` will add a rule to open all TCP ports
on the default security group.


### Using `trainctl` in a container

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


## find-non-ascii-7-characters.sh

Sometimes, showoff will crash if there are characters outside of the ASCII7
character set. This script detects and shows those characters.
