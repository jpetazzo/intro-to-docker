# Tools

Hopefully useful tools for the training material and associated course.

## trainctl

Little tool to start/stop training VMs.

It uses `cloudinit.sh` as a cloudinit payload (i.e. script that runs
when the instance boots).

### Starting training VMs

Start 10 VMs: `trainctl start 10`

This will output a tag, e.g. 2014-12-24-23-58-jpetazzo.

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

## find-non-ascii-7-characters.sh

Sometimes, showoff will crash if there are characters outside of the ASCII7
character set. This script detects and shows those characters.
