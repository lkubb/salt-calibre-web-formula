# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as calibre_web with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Calibre-Web environment files are managed:
  file.managed:
    - names:
      - {{ calibre_web.lookup.paths.config_calibre_web }}:
        - source: {{ files_switch(['calibre_web.env', 'calibre_web.env.j2'],
                                  lookup='calibre_web environment file is managed',
                                  indent_width=10,
                     )
                  }}
    - mode: '0640'
    - user: root
    - group: __slot__:salt:user.primary_group({{ calibre_web.lookup.user.name }})
    - makedirs: True
    - template: jinja
    - require:
      - user: {{ calibre_web.lookup.user.name }}
    - watch_in:
      - Calibre-Web is installed
    - context:
        calibre_web: {{ calibre_web | json }}

{%- if calibre_web.config %}

Calibre-Web has initialized the database:
  compose.running:
    - name: {{ calibre_web.lookup.paths.compose }}
{%-   for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-     if calibre_web.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ calibre_web.lookup.compose[param] }}
{%-     endif %}
{%-   endfor %}
{%-   if calibre_web.install.rootless %}
    - user: {{ calibre_web.lookup.user.name }}
{%-   endif %}
    - timeout: 20
    - require:
      - Calibre-Web is installed
    - unless:
      - fun: file.file_exists
        path: {{ calibre_web.lookup.paths.data | path_join("app.db") }}
  file.exists:
    - name: {{ calibre_web.lookup.paths.data | path_join("app.db") }}
    - retry:
        attempts: 15
        interval: 2

Calibre-Web is not running before database modification:
  compose.dead:
    - name: {{ calibre_web.lookup.paths.compose }}
{%-   for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-     if calibre_web.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ calibre_web.lookup.compose[param] }}
{%-     endif %}
{%-   endfor %}
{%-   if calibre_web.install.rootless %}
    - user: {{ calibre_web.lookup.user.name }}
{%-   endif %}
    - timeout: 20
    - require:
      - Calibre-Web is installed

Calibre-Web config is applied to the database:
  sqlite3.row_present:
    - db: {{ calibre_web.lookup.paths.data | path_join("app.db") }}
    - table: settings
    - where_sql: id=1
    - update: true
    - data: {{ calibre_web.config | json }}
    - require:
      - Calibre-Web has initialized the database
    - prereq:
      - Calibre-Web is not running before database modification
    - require:
      - file: {{ calibre_web.lookup.paths.data | path_join("app.db") }}

Calibre-Web is running again after shutdown:
  compose.running:
    - name: {{ calibre_web.lookup.paths.compose }}
{%-   for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-     if calibre_web.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ calibre_web.lookup.compose[param] }}
{%-     endif %}
{%-   endfor %}
{%-   if calibre_web.install.rootless %}
    - user: {{ calibre_web.lookup.user.name }}
{%-   endif %}
    - timeout: 20
    - require:
      - Calibre-Web is installed
    - onchanges:
      - Calibre-Web is not running before database modification
{%- endif %}
