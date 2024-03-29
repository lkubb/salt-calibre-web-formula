# vim: ft=yaml
---
calibre_web:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    compose:
      create_pod: null
      pod_args: null
      project_name: calibre_web
      remove_orphans: true
      build: false
      build_args: null
      pull: false
      service:
        container_prefix: null
        ephemeral: true
        pod_prefix: null
        restart_policy: on-failure
        restart_sec: 2
        separator: null
        stop_timeout: null
    paths:
      base: /opt/containers/calibre_web
      compose: docker-compose.yml
      config_calibre_web: calibre_web.env
      books: books
      data: data
    user:
      groups: []
      home: null
      name: calibre_web
      shell: /usr/sbin/nologin
      uid: 8004
      gid: null
    containers:
      calibre_web:
        image: ghcr.io/linuxserver/calibre-web
    media_group:
      gid: 3414
      name: mediarr
  install:
    rootless: true
    autoupdate: true
    autoupdate_service: false
    remove_all_data_for_sure: false
    podman_api: true
  config:
    config_calibre_dir: /books
    config_kepubifypath: /usr/bin/kepubify
    config_rarfile_location: /usr/bin/unrar
  container:
    google_oauth: false
    host_port: 8003
    include_calibre: true
    pgid: null
    puid: null
    tz: null
    userns_keep_id: true

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://calibre_web/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   calibre_web-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      Calibre-Web environment file is managed:
      - calibre_web.env.j2

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
