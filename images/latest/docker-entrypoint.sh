#!/bin/sh
set -e

DEFAULT_WWW_DATA_UID=$(id -u www-data)
DEFAULT_WWW_DATA_GID=$(id -g www-data)
ENTRYPOINT=/usr/bin/supervisord
SITES_DIR=/etc/nginx/sites
SITES_AVAILABLE_DIR=/etc/nginx/sites-available
SITES_ENABLED_DIR=/etc/nginx/sites-enabled

#: Docker shares users with the host system, therefore a user with the UID 0
#: (i.e. root) in the container shows up as root on the host system. Assuming
#: your user has a UID of 1001, if in your container you named this user
#: "appuser" you'd still see process started from the container and running
#: outside the container as your username. See the following article for a
#: more indepth analyis of this:
#:
#:   https://medium.com/@mccode/understanding-how-uid-and-gid-work-in-docker-containers-c37a01d01cf
#:
#: To take advantage of this and ensure that the user: "www-data" can access
#: volumes used in development, we remap the user's UID and GID values to the
#: IDs present in the environment file.
#:
#: If no remapping is being done, we ignore this and leave the user untouched.

#: If the WWW_DATA_UID variable is not set, set it to the container default
WWW_DATA_UID=${WWW_DATA_UID:-$DEFAULT_WWW_DATA_UID}
WWW_DATA_GID=${WWW_DATA_GID:-$DEFAULT_WWW_DATA_GID}

usermod -u $WWW_DATA_UID www-data
groupmod -g $WWW_DATA_GID www-data

#: <summary>
#: Convenience method for logging from this entrypoint, prepends a timestamp
#: to the message written to the console.
#: </summary>
#: <param name="message" index=1>The message to write to the console.</param>
log() {
  message=$1
  time=$(date +"%F %T %Z")
  echo -e $time $1
}


#: <summary>
#: </summary>
#: <param name="from" index=1>The path to the link being created.</param>
#: <param name="to" index=2>The target of the link</param>
link() {
  link_from=$1
  link_to=$2

  log "[DEBUG] Linking $link_from -> $link_to"
  sudo ln -sf $link_to $link_from
}


#: <summary>
#: </summary>
configure() {
  log "[INFO ] Configuring runtime environment"
  #: TODO: In the future we can modify what links are made available based
  #:       on environment variables, or some more elaborate scheme.
  link $SITES_AVAILABLE_DIR/grav $SITES_DIR/grav/default.conf
}


#: <summary>
#: Enable all of the available sites under nginx.
#:
#: This will iterate over all non-directories in `/etc/nginx/sites-available`
#: and create a symlink to the file from the `/etc/nginx/sites-enabled`
#: directory.
#: </summary>
enable_available_sites() {
  log "[INFO ] Activating available nginx sites"
  for target in $(find $SITES_AVAILABLE_DIR); do
    if [ ! -d $target ]; then
      link=$SITES_ENABLED_DIR/$(basename $target)
      log "[DEBUG] Enabling site: $link -> $target"
      sudo ln -sf $target $link
    fi
  done
}


#: <summary>
#: If the ENABLE_XDEBUG flag is set to `true` (or any case variation there
#: of), enable the XDebug extension using the Unix stream editor (sed)
#: utility.
#: </summary>
enable_xdebug() {
  log "[INFO ] Checking to see if XDebug should be enabled (ENABLE_XDEBUG=$ENABLE_XDEBUG)"
  if [ $(echo $ENABLE_XDEBUG | grep -i "^true$") ]; then
    log "[DEBUG] Enabling XDebug..."
    sudo sed -i "s/^;zend_extension=xdebug.so$/zend_extension=xdebug.so/" /etc/php/mods-available/xdebug.ini
    log "[DEBUG] ... XDebug is now enabled!"
  else
    log "[DEBUG] Disabling XDebug..."
    sudo sed -i "s/^zend_extension=xdebug.so$/;zend_extension=xdebug.so/" /etc/php/mods-available/xdebug.ini
    log "[DEBUG] ... XDebug is now disabled!"
  fi
}

#: <summary>
#: </summary>
fix_grav() {
  if ! [ -e $WWW_DIR/grav/user/config/system.yaml ]; then
    log "[INFO ] No user files found, cooying them now..."
    #rsync -a /tmp/grav-$GRAV_VERSION/user/ /var/www/html/user
  fi
}

own_grav() {
  log "[INFO ] Taking ownership of Grav system files"
  sudo chown -Rf www-data:www-data $WWW_DIR/grav || true
}


#: Visually separate breaks in log activity.
echo -e "\n\n"

configure
enable_available_sites
enable_xdebug
fix_grav
own_grav

log "[INFO ] Starting web server"
log "[INFO ] $(date +'%b %d, %Y %H:%M:%S %z (%l:%M:%S %p %Z)')"
log "[INFO ] Ready!"
log "[DEBUG] > $ENTRYPOINT $@"

$ENTRYPOINT "$@"