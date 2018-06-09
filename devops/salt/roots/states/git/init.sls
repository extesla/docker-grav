{% from 'map.jinja' import config with context %}

git:
  pkg.installed

github-host:
  ssh_known_hosts.present:
    - name: github.com
    - user: {{ config['user'] }}
    #- fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48
