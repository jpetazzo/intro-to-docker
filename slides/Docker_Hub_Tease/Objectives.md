<!SLIDE>
# Lesson ~~~SECTION:MAJOR~~~: Uploading our images to the Docker Hub

We have built our first images.

If we were so inclined, we could share those images through the Docker Hub.

We won't do it since we don't want to force everyone to create a Docker Hub account (although it's free, yay!) but the steps would be:

* have an account on the Docker Hub
* tag our image accordingly (i.e. `username/imagename`)
* `docker push username/imagename`

Anybody can now `docker run username/imagename` from any Docker host.

Images can be set to be private as well.
