docker:
  group.present

ubuntu:
  user.present:
    - shell: /bin/bash
    - groups:
      - sudo
      - docker

vagrant:
  user.present:
    - groups:
      - sudo
      - docker
