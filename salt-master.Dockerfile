FROM debian:stretch

ARG version=2017.7
ENV VERSION $version

RUN apt-get -qq update && \
    apt-get install -y wget gnupg2 && \
    wget -O - https://repo.saltstack.com/apt/debian/9/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add - && \
    echo "deb http://repo.saltstack.com/apt/debian/9/amd64/${VERSION} jessie main" && \
    apt-get update && apt-get install -y salt-master reclass && \
    mkdir -p /etc/reclass /var/run/salt /etc/salt/pki/master/minions && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd --system salt && \
    chown -R salt:salt /etc/salt /var/cache/salt /var/log/salt /var/run/salt && \
    echo "user: salt" >> /etc/salt/master

ENV TINI_VERSION 0.14.0
ENV TINI_SHA 6c41ec7d33e857d4779f14d9c74924cab0c7973485d2972419a3b7c7620ff5fd

# Use tini as subreaper in Docker container to adopt zombie processes
RUN wget https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -O /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c -

# Setup salt-formulas repository
RUN echo "deb http://ppa.launchpad.net/salt-formulas/ppa/ubuntu xenial main" >/etc/apt/sources.list.d/salt-formulas.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 39847281B4B4F5E69A9012612B06BC3AFC7315C0
RUN apt-get -qq update && \
    apt-get install -y salt-formula-* && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#VOLUME ['/etc/salt/pki', '/srv/salt']
ADD files/reclass-config.yml /etc/reclass/
ADD files/reclass.conf /etc/salt/master.d/
ADD files/env.conf /etc/salt/master.d/

EXPOSE 4505 4506

COPY files/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/tini", "--", "/entrypoint.sh"]
