<!SLIDE>
# Lesson ~~~SECTION:MAJOR~~~: Copying files during the build

## Objectives

So far, we have installed things in our container images
by downloading packages.

We can also copy files from the *build context* to the
container that we are building.

Remember: the *build context* is the directory containing
the Dockerfile.

In this chapter, we will learn a new Dockerfile keyword: `COPY`.