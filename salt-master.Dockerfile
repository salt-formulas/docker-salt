FROM debian:stretch

MAINTAINER Filip Pytloun <filip@pytloun.cz>

ARG version=2018.3
ENV VERSION $version

ENV DEBIAN_FRONTEND noninteractive

# Install salt
RUN apt-get -qq update && \
    apt-get install -y wget gnupg2 && \
    wget -O - https://repo.saltstack.com/apt/debian/9/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add - && \
    echo "deb http://repo.saltstack.com/apt/debian/9/amd64/${VERSION} stretch main" >/etc/apt/sources.list.d/saltstack.list && \
    apt-get update && apt-get install -y salt-master salt-api pwgen git make myrepos && \
    mkdir -p /etc/reclass /var/run/salt /etc/salt/pki/master/minions && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd --system salt && \
    chown -R salt:salt /etc/salt /var/cache/salt /var/log/salt /var/run/salt && \
    echo "user: salt" >> /etc/salt/master

# Install reclass
RUN apt-get -qq update && \
    apt-get install --no-install-recommends -y python-pip python-ddt python-pyparsing && \
    pip install -e git+https://github.com/salt-formulas/reclass.git#egg=reclass && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use tini as subreaper in Docker container to adopt zombie processes
ENV TINI_VERSION 0.18.0
ENV TINI_SHA eadb9d6e2dc960655481d78a92d2c8bc021861045987ccd3e27c7eae5af0cf33

RUN wget https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -O /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c -

# Install molten
ENV MOLTEN_VERSION 0.3.1
ENV MOLTEN_MD5 04483620978a3167827bdd1424e34505
ADD https://github.com/martinhoefling/molten/releases/download/v${MOLTEN_VERSION}/molten-${MOLTEN_VERSION}.tar.gz molten-${MOLTEN_VERSION}.tar.gz
RUN echo "${MOLTEN_MD5}  molten-${MOLTEN_VERSION}.tar.gz" | md5sum --check
RUN mkdir -p /opt/molten && tar -xf molten-${MOLTEN_VERSION}.tar.gz -C /opt/molten --strip-components=1

# Setup salt-formulas from git
RUN git clone https://github.com/salt-formulas/salt-formulas.git /tmp/salt-formulas && \
    cd /tmp/salt-formulas && \
    make submodules && \
    make update && \
    make install && \
    cd && rm -rf /tmp/salt-formulas

# Setup salt-formulas repository
#RUN echo "deb http://ppa.launchpad.net/salt-formulas/ppa/ubuntu xenial main" >/etc/apt/sources.list.d/salt-formulas.list && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 39847281B4B4F5E69A9012612B06BC3AFC7315C0 && \
#    apt-get -qq update && \
#    apt-get install -y salt-formula-* && \
#    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#VOLUME ['/etc/salt/pki', '/srv/salt']
ADD files/reclass-config.yml /etc/reclass/
ADD files/reclass.conf /etc/salt/master.d/
ADD files/env.conf /etc/salt/master.d/
ADD files/api.conf /etc/salt/master.d/
ADD files/auth.conf /etc/salt/master.d/

EXPOSE 4505 4506 8000

COPY files/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/tini", "--", "/entrypoint.sh"]
