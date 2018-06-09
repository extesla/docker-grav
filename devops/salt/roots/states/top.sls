#
# Deploy.
#
base:
  '*':    
    #: Configure NFS for shared folders with Linux/OS X
    - nfs.server

    - default
    - default.users
    - default.structure
    - git
    - docker
    - docker.compose
