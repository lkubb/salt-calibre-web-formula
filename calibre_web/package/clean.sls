# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as calibre_web with context %}

include:
  - {{ sls_config_clean }}

Calibre-Web is absent:
  compose.removed:
    - name: {{ calibre_web.lookup.paths.compose }}
    - volumes: {{ calibre_web.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if calibre_web.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ calibre_web.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if calibre_web.install.rootless %}
    - user: {{ calibre_web.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

Calibre-Web compose file is absent:
  file.absent:
    - name: {{ calibre_web.lookup.paths.compose }}
    - require:
      - Calibre-Web is absent

Calibre-Web user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ calibre_web.lookup.user.name }}
    - enable: false

Calibre-Web user account is absent:
  user.absent:
    - name: {{ calibre_web.lookup.user.name }}
    - purge: {{ calibre_web.install.remove_all_data_for_sure }}
    - require:
      - Calibre-Web is absent

{%- if calibre_web.install.remove_all_data_for_sure %}

Calibre-Web paths are absent:
  file.absent:
    - names:
      - {{ calibre_web.lookup.paths.base }}
    - require:
      - Calibre-Web is absent
{%- endif %}
