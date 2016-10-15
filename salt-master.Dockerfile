FROM debian:jessie

ARG version=2016.3
ENV VERSION $version

RUN apt-get -qq update && \
    apt-get install -y wget && \
    wget -O - https://repo.saltstack.com/apt/debian/8/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add - && \
    echo "deb http://repo.saltstack.com/apt/debian/8/amd64/${VERSION} jessie main" && \
    apt-get update && apt-get install -y salt-master reclass && \
    mkdir /etc/reclass && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


VOLUME ['/etc/salt/pki', '/srv/salt']
ADD files/reclass-config.yml /etc/reclass/
ADD files/reclass.conf /etc/salt/master.d/
ADD files/env.conf /etc/salt/master.d/
EXPOSE 4505 4506
ENTRYPOINT ["/usr/bin/salt-master", "--log-file-level=quiet", "--log-level=info"]
