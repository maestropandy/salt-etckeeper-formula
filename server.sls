{%- from "etckpeer/map.jinja" import server with context %}
{%- if server.enabled %}

etckeeper_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/etckeeper/etckeeper.conf:
  file.managed:
    - source: salt://etckeeper/files/etckeeper.conf
    - mode: 644
    - require:
      - pkg: etckeeper_packages

etckeeper_initial_commit:
  cmd.run:
    - cwd: /etc
    - name: |
        /usr/bin/etckeeper init
        /usr/bin/etckeeper commit 'Initial commit'
    - unless: test -d /etc/.git

etckeeper_commit_at_end:
  cmd.run:
    - order: last
    - cwd: /etc
    - name: '/usr/bin/etckeeper commit "Changes found prior to start of salt run #salt-end"'
    - onlyif: 'test -d /etc/.git && test -n "$(git status --porcelain)"'
{%- endif %}
