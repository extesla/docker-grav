# Pillars.
#   Pillars are used to store secure and insecure data pertaining to minions.
#   Each entry in this file (top.sls) should correspond to a state which it
#   matches, e.g. nodejs -> /srv/pillar/nodejs.sls; this creates a consistent
#   understanding of the system and allows developers to make assumptions that
#   NodeJS related variables will be the only ones found in the nodejs.sls.
base:
  '*':
    - environment
    - docker
