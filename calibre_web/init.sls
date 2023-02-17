# vim: ft=sls

{#-
    *Meta-state*.

    This installs the calibre_web containers,
    manages their configuration and starts their services.
#}

include:
  - .package
  - .config
  - .service
