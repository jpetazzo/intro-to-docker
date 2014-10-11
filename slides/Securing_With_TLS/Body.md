<!SLIDE>
# Why should I care?

* Docker does not have any access controls on its network API unless you use TLS! 

<!SLIDE>
# What is TLS

* TLS is Transport Layer Security. 
* The protocol that secures websites with `https` URLs. 
* Uses Public Key Cryptography to encrypt connections.
* Keys are signed with Certificates which are maintained by a trusted party.
* These Certificates indicate that a trusted party believes the server is who it says it is.
* Each transaction is therefor encrypted *and* authenticated.

<!SLIDE>
# How Docker Uses TLS

* Docker provides mechanisms to authenticate both the server the client to _each other_.
* Provides strong authentication, authorization and encryption for any API connection over the network.
* Client keys can be distributed to authorized clients

<!SLIDE>
# Environment Preparation

* You need to make sure that OpenSSL version 1.0.1 is installed on your machine. 
* Make a directory for all of the files to reside.
* Make sure that the directory is protected and backed up!
* *Treat these files the same as a root password.*

<!SLIDE>
# Creating a Certificate Authority

First, initialize the CA serial file and generate CA private and public
keys:

	@@@ Sh
    $ echo 01 > ca.srl
    $ openssl genrsa -des3 -out ca-key.pem 2048
    $ openssl req -new -x509 -days 365 -key ca-key.pem -out ca.pem

We will use the `ca.pem` file to sign all of the other keys later.

<!SLIDE>
# Create and Sign the Server Key
Now that we have a CA, we can create a server key and certificate
signing request. Make sure that `CN` matches the hostname you run the Docker daemon on:

	@@@ Sh
    $ openssl genrsa -des3 -out server-key.pem 2048
    $ openssl req -subj '/CN=**<Your Hostname Here>**' -new -key server-key.pem -out server.csr
    $ openssl rsa -in server-key.pem -out server-key.pem

Next we're going to sign the key with our CA:

	@@@ Sh
    $ openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem \
      -out server-cert.pem

<!SLIDE>
# Create and Sign the Client Key

	@@@ Sh
    $ openssl genrsa -des3 -out client-key.pem 2048
    $ openssl req -subj '/CN=client' -new -key client-key.pem -out client.csr
    $ openssl rsa -in client-key.pem -out client-key.pem

To make the key suitable for client authentication, create a extensions
config file:

	@@@ Sh
    $ echo extendedKeyUsage = clientAuth > extfile.cnf

Now sign the key:

	@@@ Sh
    $ openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem \
      -out client-cert.pem -extfile extfile.cnf

<!SLIDE>
# Configuring the Docker Daemon for TLS

* By default, Docker does not listen on the network at all.
* To enable remote connections, use the `-H` flag.
* The assigned port for Docker over TLS is `2376`.

		@@@ Sh
		$ sudo docker -d --tlsverify --tlscacert=ca.pem --tlscert=server-cert.pem --tlskey=server-key.pem -H=0.0.0.0:2376

_Note: You will need to modify the startup scripts on your server for this to be permanent! The keys should be placed in a secure system directory, such as /etc/docker._ 



<!SLIDE>
# Configuring the Docker Client for TLS

If you want to secure your Docker client connections by default, you can move the key files
to the `.docker` directory in your home directory. Set the `DOCKER_HOST` variable as well.

	@@@ Sh
    $ cp ca.pem ~/.docker/ca.pem
    $ cp client-cert.pem ~/.docker/cert.pem
    $ cp client-key.pem ~/.docker/key.pem
    $ export DOCKER_HOST=tcp://:2376

Then you can run docker with the `--tlsverify` option.

	@@@ Sh
    $ docker --tlsverify ps

<!SLIDE>
# Section Summary

We learned how to:

* Create a TLS Certificate Authority
* Create TLS Keys
* Sign TLS Keys
* Use these keys with Docker

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Set up a CA

1. Initalize the CA in an empty directory.

		@@@ Sh
		$ mkdir docker-ca
		$ chmod 0700 docker-ca
		$ cd docker-ca
	    $ echo 01 > ca.srl
	    $ openssl genrsa -des3 -out ca-key.pem 2048
	    $ openssl req -new -x509 -days 365 -key ca-key.pem -out ca.pem

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Generate Server Key and Sign it

1. Generate the Server Key

		@@@ Sh
	    $ openssl genrsa -des3 -out server-key.pem 2048
	    $ openssl req -subj '/CN=**<Your Hostname Here>**' -new -key server-key.pem -out server.csr
	    $ openssl rsa -in server-key.pem -out server-key.pem

2. Sign the key with our CA:

		@@@ Sh
	    $ openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem \
	      -out server-cert.pem

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Generate Client Key and Sign it

1. Generate the Client Key

		@@@ Sh
	    $ openssl genrsa -des3 -out client-key.pem 2048
	    $ openssl req -subj '/CN=client' -new -key client-key.pem -out client.csr
	    $ openssl rsa -in client-key.pem -out client-key.pem

2. Create an extensions config file

		@@@ Sh
	    $ echo extendedKeyUsage = clientAuth > extfile.cnf

3. Sign the key

		@@@ Sh
	    $ openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem \
	      -out client-cert.pem -extfile extfile.cnf

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Change Docker startup options

1. Copy the keys from the `docker-ca` directory to `/etc/docker`

		@@@ Sh
		$ sudo mkdir /etc/docker
		$ sudo chown docker:docker /etc/docker
		$ sudo chmod 0700 /etc/docker
		$ sudo cp ~/docker-ca/{ca,server-key,server-cert}.pem /etc/docker

2. Edit the file `/etc/default/docker`

		@@@ Sh
		$ sudo nano /etc/default/docker

3. Change the line:

		@@@ Sh
		DOCKER_OPTS="-H tcp://127.0.0.1:4243 -H unix:///var/run/docker.sock"
to

		@@@ Sh
		DOCKER_OPTS="-H tcp://127.0.0.1:2376  --tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/server-cert.pem --tlskey=/etc/docker/server-key.pem"

and save the file.

4. Restart docker

		@@@ Sh
		$ sudo service docker restart

<!SLIDE supplemental exercises>
# Lab ~~~SECTION:MAJOR~~~.~~~SECTION:MINOR~~~: Set up the client and test.

1. Copy the keys into the `~/.docker` directory
	
		@@@ Sh
		$ mkdir ~/.docker
		$ cp ~/docker-ca/ca.pem ~/.docker
		$ cp ~/docker-ca/client-key.pem ~/.docker/key.pem
		$ cp ~/docker-ca/client-cert.pem ~/.docker/cert.pem

2. Test the connection
	
		@@@ Sh
		$ docker --tlsverify ps

All done!
