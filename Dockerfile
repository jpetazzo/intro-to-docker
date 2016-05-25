FROM ubuntu:14.04
MAINTAINER Education Team at Docker <education@docker.com>

RUN apt-get update
RUN apt-get install -y curl wget git ruby ruby-dev libxml2-dev libxslt-dev build-essential zlib1g-dev

# Let's install prince. The first dpkg will fail because of missing dependencies,
# so we'll install the dependencies with "install -f" then try again.
WORKDIR /usr/src
RUN wget http://www.princexml.com/download/prince_9.0-5_ubuntu14.04_amd64.deb
RUN dpkg -i prince_9.0-5_ubuntu14.04_amd64.deb || true
RUN apt-get install -fy
RUN dpkg -i prince_9.0-5_ubuntu14.04_amd64.deb

# Install showoff.
WORKDIR /usr/src
RUN git clone https://github.com/puppetlabs/showoff.git
WORKDIR /usr/src/showoff
RUN git checkout v0.10.2
RUN gem build showoff.gemspec
RUN gem install --no-rdoc --no-ri ./showoff-*.gem

COPY /slides/ /slides/
WORKDIR /slides

CMD [ "showoff", "serve" ]

EXPOSE 9090
