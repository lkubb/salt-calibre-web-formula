Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``calibre_web``
^^^^^^^^^^^^^^^
*Meta-state*.

This installs the calibre_web containers,
manages their configuration and starts their services.


``calibre_web.package``
^^^^^^^^^^^^^^^^^^^^^^^
Installs the calibre_web containers only.
This includes creating systemd service units.


``calibre_web.config``
^^^^^^^^^^^^^^^^^^^^^^
Manages the configuration of the calibre_web containers.
Has a dependency on `calibre_web.package`_.


``calibre_web.service``
^^^^^^^^^^^^^^^^^^^^^^^
Starts the calibre_web container services
and enables them at boot time.
Has a dependency on `calibre_web.config`_.


``calibre_web.clean``
^^^^^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``calibre_web`` meta-state
in reverse order, i.e. stops the calibre_web services,
removes their configuration and then removes their containers.


``calibre_web.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the calibre_web containers
and the corresponding user account and service units.
Has a depency on `calibre_web.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``calibre_web.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the calibre_web containers
and has a dependency on `calibre_web.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``calibre_web.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the calibre_web container services
and disables them at boot time.


