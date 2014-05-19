FROM ubuntu:12.04
MAINTAINER Education Team at Docker <education@docker.com>

ENV VERSION 0.0.1

RUN apt-get update && apt-get install -y curl wget git ruby rubygems ruby-dev libxml2-dev libxslt-dev
RUN git clone https://github.com/puppetlabs/showoff.git
RUN cd showoff && gem build showoff.gemspec && gem install --no-rdoc --no-ri ./showoff-*.gem 

CMD ["/bin/bash"]
