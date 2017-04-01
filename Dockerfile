FROM fpco/pid1:16.04

ENV HOME /home/stackage
ENV LANG en_US.UTF-8
ENV PATH /opt/ghc/8.0.2/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin

ADD debian-bootstrap.sh /tmp/debian-bootstrap.sh
RUN /tmp/debian-bootstrap.sh && rm /tmp/debian-bootstrap.sh
