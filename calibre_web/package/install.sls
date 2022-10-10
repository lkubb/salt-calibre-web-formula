# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as calibre_web with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Calibre-Web user account is present:
  user.present:
{%- for param, val in calibre_web.lookup.user.items() %}
{%-   if val is not none and param not in ["groups", "gid"] %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ calibre_web.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false
{%- if not calibre_web.lookup.media_group.gid %}]
    - gid: {{ calibre_web.lookup.user.gid or "null" }}
{%- else %}
    - gid: {{ calibre_web.lookup.media_group.gid }}
    - require:
      - group: {{ calibre_web.lookup.media_group.name }}
  group.present:
    - name: {{ calibre_web.lookup.media_group.name }}
    - gid: {{ calibre_web.lookup.media_group.gid }}
{%- endif %}

Calibre-Web user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ calibre_web.lookup.user.name }}
    - enable: {{ calibre_web.install.rootless }}
    - require:
      - user: {{ calibre_web.lookup.user.name }}

Calibre-Web paths are present:
  file.directory:
    - names:
      - {{ calibre_web.lookup.paths.base }}
    - user: {{ calibre_web.lookup.user.name }}
    - group: __slot__:salt:user.primary_group({{ calibre_web.lookup.user.name }})
    - makedirs: true
    - require:
      - user: {{ calibre_web.lookup.user.name }}

Calibre-Web compose file is managed:
  file.managed:
    - name: {{ calibre_web.lookup.paths.compose }}
    - source: {{ files_switch(['docker-compose.yml', 'docker-compose.yml.j2'],
                              lookup='Calibre-Web compose file is present'
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ calibre_web.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - makedirs: true
    - context:
        calibre_web: {{ calibre_web | json }}

Calibre-Web is installed:
  compose.installed:
    - name: {{ calibre_web.lookup.paths.compose }}
{%- for param, val in calibre_web.lookup.compose.items() %}
{%-   if val is not none and param not in ["service"] %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- if calibre_web.container.userns_keep_id and calibre_web.install.rootless %}
    - podman_create_args:
{%-   if calibre_web.lookup.compose.create_pod is false %}
{#-     post-map.jinja ensures this is in pod_args if pods are in use #}
        # this maps the host uid/gid to the same ones inside the container
        # important for network share access
        # https://github.com/containers/podman/issues/5239#issuecomment-587175806
      - userns: keep-id
{%-   endif %}
        # linuxserver images generally assume to be started as root,
        # then drop privileges as defined in PUID/PGID.
      - user: 0
{%- endif %}
{%- for param, val in calibre_web.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ calibre_web.lookup.paths.compose }}
{%- if calibre_web.install.rootless %}
    - user: {{ calibre_web.lookup.user.name }}
    - require:
      - user: {{ calibre_web.lookup.user.name }}
{%- endif %}

{%- if calibre_web.install.autoupdate_service is not none %}

Podman autoupdate service is managed for Calibre-Web:
{%-   if calibre_web.install.rootless %}
  compose.systemd_service_{{ "enabled" if calibre_web.install.autoupdate_service else "disabled" }}:
    - user: {{ calibre_web.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if calibre_web.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
