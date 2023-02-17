# vim: ft=sls

{#-
    Starts the calibre_web container services
    and enables them at boot time.
    Has a dependency on `calibre_web.config`_.
#}

include:
  - .running
