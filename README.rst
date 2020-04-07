##################################
Hadoop v3.2.1 - Pseudo Distributed
##################################

Quick and easy way to get Hadoop running in pseudo distributed mode using docker.

See `Hadoop docs <https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html#Configuration>`_ for more information.

*************
Prerequisties
*************

- `Docker <https://docs.docker.com/install/>`_

***************
Getting Started
***************

Get the code and change into the top level `git` project directory::

    $ git clone https://github.com/loum/hadoop-pseudo.git && cd hadoop-pseudo

.. note::

    Run all commands from the top-level directory of the `git` repository.

For first-time setup, get the `Makester project <https://github.com/loum/makester.git>`_::

    $ git submodule update --init

Keep `Makester project <https://github.com/loum/makester.git>`_ up-to-date with::

    $ git submodule update --remote --merge

Setup the environment::

    $ make init

************
Getting Help
************

There should be a `make` target to be able to get most things done.  Check the help for more information::

    $ make help

***********
Image Build
***********

::

    $ make bi

*******************
Start the Container
*******************

::

    $ make run

********************
Interact with Hadoop
********************

Run `hadoop` as the `hdfs` user::

    $ docker exec hadoop-pseudo /opt/hadoop/bin/hdfs version

Check the `Hadoop Command Reference <https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html>`_ for more.

******************
Stop the Container
******************

::

    $ make stop
