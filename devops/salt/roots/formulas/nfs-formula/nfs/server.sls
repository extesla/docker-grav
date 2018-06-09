{% from "nfs/map.jinja" import nfs with context %}
{% set nfs_exports = salt['pillar.get']('nfs:server:exports') %}

nfs-server-deps:
    pkg.installed:
        - pkgs: {{ nfs.pkgs_server|json }}

{% if nfs_exports %}
/etc/exports:
  file.managed:
    - source: salt://nfs/files/exports
    - template: jinja
    - context:
      - nfs_exports: {{ nfs_exports }} 
    - watch_in:
      - service: nfs-service
{% endif %}

nfs-service:
  service.running:
    - name: {{ nfs.service_name }}
    - enable: True
