FROM fedora
MAINTAINER Education Team at Docker <education@docker.com>

RUN yum install -y curl wget git lxc-docker

CMD ["/usr/bin/bash"]
