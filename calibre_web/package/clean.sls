# vim: ft=sls

{#-
    Removes the calibre_web containers
    and the corresponding user account and service units.
    Has a depency on `calibre_web.config.clean`_.
    If ``remove_all_data_for_sure`` was set, also removes all data.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as calibre_web with context %}

include:
  - {{ sls_config_clean }}

{%- if calibre_web.install.autoupdate_service %}

Podman autoupdate service is disabled for Calibre-Web:
{%-   if calibre_web.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ calibre_web.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

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

{%- if calibre_web.install.podman_api %}

Calibre-Web podman API is unavailable:
  compose.systemd_service_dead:
    - name: podman
    - user: {{ calibre_web.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ calibre_web.lookup.user.name }}

Calibre-Web podman API is disabled:
  compose.systemd_service_disabled:
    - name: podman
    - user: {{ calibre_web.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ calibre_web.lookup.user.name }}
{%- endif %}

Calibre-Web user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ calibre_web.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ calibre_web.lookup.user.name }}

Calibre-Web user account is absent:
  user.absent:
    - name: {{ calibre_web.lookup.user.name }}
    - purge: {{ calibre_web.install.remove_all_data_for_sure }}
    - require:
      - Calibre-Web is absent
    - retry:
        attempts: 5
        interval: 2

{%- if calibre_web.install.remove_all_data_for_sure %}

Calibre-Web paths are absent:
  file.absent:
    - names:
      - {{ calibre_web.lookup.paths.base }}
    - require:
      - Calibre-Web is absent
{%- endif %}
