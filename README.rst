############################################
Hadoop v3.2.1 - Pseudo Distributed on Docker
############################################

Quick and easy way to get Hadoop running in `pseudo-distributed <https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html#Pseudo-Distributed_Operation>`_ mode using `Docker <https://docs.docker.com/install/>`_.

Docker image is based on `Ubuntu Bionic <https://hub.docker.com/_/ubuntu?tab=description>`_

See `Hadoop docs <https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html#Configuration>`_ for more information.

************
Quick Start
************

Impatient and just want Hadoop quickly?::

    $ docker run --rm -ti -d \
     --name hadoop-pseudo \
     loum/hadoop-pseudo:latest

More at `<https://hub.docker.com/r/loum/hadoop-pseudo>`_

*************
Prerequisites
*************

- `Docker <https://docs.docker.com/install/>`_
- `GNU make <https://www.gnu.org/software/make/manual/make.html>`_

***************
Getting Started
***************

Get the code and change into the top level ``git`` project directory::

    $ git clone https://github.com/loum/hadoop-pseudo.git && cd hadoop-pseudo

.. note::

    Run all commands from the top-level directory of the ``git`` repository.

For first-time setup, get the `Makester project <https://github.com/loum/makester.git>`_::

    $ git submodule update --init

Keep `Makester project <https://github.com/loum/makester.git>`_ up-to-date with::

    $ make submodule-update

Setup the environment::

    $ make init

************
Getting Help
************

There should be a ``make`` target to be able to get most things done.  Check the help for more information::

    $ make help

***********
Image Build
***********

Configuration
=============

Hadoop configuration settings and project file mappings as follows:

- `Hadoop core-default.xml <https://hadoop.apache.org/docs/r3.2.1/hadoop-project-dist/hadoop-common/core-default.xml>`_ | `Image core-site.xml <https://github.com/loum/hadoop-pseudo/blob/master/files/core-site.xml>`_
- `Hadoop hdfs-default.xml <https://hadoop.apache.org/docs/r3.2.1/hadoop-project-dist/hadoop-common/hdfs-default.xml>`_ | `Image hdfs-site.xml <https://github.com/loum/hadoop-pseudo/blob/master/files/hdfs-site.xml>`_
- `Hadoop mapred-default.xml <https://hadoop.apache.org/docs/r3.2.1/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml>`_ | `Image hdfs-site.xml <https://github.com/loum/hadoop-pseudo/blob/master/files/hdfs-site.xml>`_
- `Hadoop yarn-default.xml <https://hadoop.apache.org/docs/r3.2.1/hadoop-yarn/hadoop-yarn-common/yarn-default.xml>`_ | `Image yarn-site.xml <https://github.com/loum/hadoop-pseudo/blob/master/files/yarn-site.xml>`_

When you are ready to build the image::

    $ make bi

********************
Interact with Hadoop
********************

To start::

    $ make run

To start the container and wait for all Hadoop services to initiate::

    $ make controlled-run

Run ``hadoop`` as the ``hdfs`` user::

    $ docker exec hadoop-pseudo /opt/hadoop/bin/hdfs version

Check the `Hadoop Command Reference <https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html>`_ for more.

To stop::

    $ make stop

Web Interfaces
==============

The following web interfaces are available to view configurations and logs:

- `Hadoop NameNode web UI <http://localhost:9870>`_
- `YARN ResourceManager web UI <http://localhost:8088>`_
- `MapReduce JobHistory Server web UI <http://localhost:19888>`_

*********
Image Tag
*********

To tag the image as ``latest``::

    $ make tag

Or to apply tagging convention using ``<hadoop-version>-<image-release-number>``::

    $ make tag MAKESTER__IMAGE_TARGET_TAG=3.2.1-3
