srv-www:
  file.directory:
    - name: /srv/www
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True

var-log-nginx:
  file.directory:
    - name: /var/log/nginx
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group

var-log-www:
  file.directory:
    - name: /var/log/www
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
