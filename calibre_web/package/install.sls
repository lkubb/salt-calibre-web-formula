# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as calibre_web with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Calibre-Web user account is present:
  user.present:
{%- for param, val in calibre_web.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ calibre_web.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false

Calibre-Web user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ calibre_web.lookup.user.name }}
    - enable: {{ calibre_web.install.rootless }}

Calibre-Web paths are present:
  file.directory:
    - names:
      - {{ calibre_web.lookup.paths.base }}
    - user: {{ calibre_web.lookup.user.name }}
    - group: {{ calibre_web.lookup.user.name }}
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
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
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
