# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``calibre_web`` meta-state
    in reverse order, i.e. stops the calibre_web services,
    removes their configuration and then removes their containers.
#}

include:
  - .service.clean
  - .config.clean
  - .package.clean
