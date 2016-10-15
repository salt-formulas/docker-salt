======================
SaltStack Docker Image
======================

Docker images to run SaltStack with Reclass as pillar backend as Docker
container.

Build
=====

.. code-block:: bash

    docker build -t salt-master -f salt-master.Dockerfile --build-args version=latest .

Run
===

First create directories on your host and set permissions:

.. code-block:: bash

    mkdir -p /srv/salt/reclass /srv/salt/env /srv/salt/pki
    chown 999:999 /srv/salt/pki

Run salt-master manually:

.. code-block:: bash

    docker run -d -v /srv/salt/pki:/etc/salt/pki -v /srv/salt:/srv/salt salt-master

Or use docker-compose:

.. code-block:: bash

    docker-compose up -d

Configuration
=============

You should also get some formulas into ``/srv/salt/env`` directory and clone
reclass into ``/srv/salt/reclass``.

If you want to make some customizations (eg. on environment locations, add new
volume as ``/etc/salt/master.d/env.conf`` or ``/etc/salt/master.d`` to replace
custom configuration completely.
