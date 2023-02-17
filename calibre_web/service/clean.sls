# vim: ft=sls


{#-
    Stops the calibre_web container services
    and disables them at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as calibre_web with context %}

calibre_web service is dead:
  compose.dead:
    - name: {{ calibre_web.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if calibre_web.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ calibre_web.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if calibre_web.install.rootless %}
    - user: {{ calibre_web.lookup.user.name }}
{%- endif %}

calibre_web service is disabled:
  compose.disabled:
    - name: {{ calibre_web.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if calibre_web.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ calibre_web.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if calibre_web.install.rootless %}
    - user: {{ calibre_web.lookup.user.name }}
{%- endif %}
