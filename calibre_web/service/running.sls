# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as calibre_web with context %}

include:
  - {{ sls_config_file }}

Calibre-Web service is enabled:
  compose.enabled:
    - name: {{ calibre_web.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if calibre_web.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ calibre_web.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - Calibre-Web is installed
{%- if calibre_web.install.rootless %}
    - user: {{ calibre_web.lookup.user.name }}
{%- endif %}

Calibre-Web service is running:
  compose.running:
    - name: {{ calibre_web.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if calibre_web.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ calibre_web.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if calibre_web.install.rootless %}
    - user: {{ calibre_web.lookup.user.name }}
{%- endif %}
    - watch:
      - Calibre-Web is installed
