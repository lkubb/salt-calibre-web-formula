# vim: ft=sls

{#-
    Removes the configuration of the calibre_web containers
    and has a dependency on `calibre_web.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as calibre_web with context %}

include:
  - {{ sls_service_clean }}

Calibre-Web environment files are absent:
  file.absent:
    - names:
      - {{ calibre_web.lookup.paths.config_calibre_web }}
    - require:
      - sls: {{ sls_service_clean }}
