# Manual operation

You shouldn't do this, but if you want to do it anyway, here it goes.


## Showoff

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


### Generating PDFs

1. Install PrinceXML - http://www.princexml.com/download/
2. Launch Showoff - `showoff server`
3. Browse to the /print URLs.

        http://localhost:9090/print
        http://localhost:9090/supplemental/exercises/print

4. Use Prince to product the PDFs.

        $ prince http://localhost:9090/print -o DockerSlides.pdf
        $ prince http://localhost:9090/supplemental/exercises/print -o DockerExercises.pdf
