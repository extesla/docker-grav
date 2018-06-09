{% set kernelrelease = salt['grains.get']('kernelrelease') -%}

linux-kernel-dependencies:
  pkg.installed:
    - pkgs:
      - linux-image-extra-{{ kernelrelease }}
      - linux-image-extra-virtual
      - aufs-tools

server-dependencies:
  pkg.installed:
    - pkgs:
      - acl
      - curl
      - libcurl4-openssl-dev
      - libgcrypt11-dev
      - libmcrypt-dev
      - libmhash-dev
      - libmhash2
      - libpcre3
      - libpcre3-dev
      - libssl-dev
      - libxml2-dev
      - openssl
      - python-dev
      - siege
