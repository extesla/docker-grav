#!/usr/bin/env bash

ETC_APT_DIR=/etc/apt
PATH_TO_APT_CONF=$ETC_APT_DIR/apt.conf

function log() {
  message=$1
  time=$(date +"%FT%T")
  echo -e $time $1; tput sgr0
}

log "[INFO ] Rematerializing: $PATH_TO_APT_CONF"
sudo rm -rf $PATH_TO_APT_CONF
sudo mkdir -p $ETC_APT_DIR
sudo touch $PATH_TO_APT_CONF

log "[INFO ] Adding timeouts to apt.conf"
echo "Acquire::http::Timeout \"10\";" | sudo tee -a $PATH_TO_APT_CONF
echo "Acquire::ftp::Timeout \"10\";" | sudo tee -a $PATH_TO_APT_CONF

if [ ! -e "/sbin/initctl" ]
then
  # Apparently there are issues with upstart and connecting to sockets in
  # Ubuntu on virtual hosts, you have to redirect the response to "true".
  #
  # see: https://www.nesono.com/node/368
  sudo dpkg-divert --local --rename --add /sbin/initctl
  ln -s /bin/true /sbin/initctl
fi
