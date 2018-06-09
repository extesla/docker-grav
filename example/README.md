Grav Example
============

## Configuring Grav for Development

The Grav application is owned and run by the `www-data` user. In productionthis is fine, because everything is self-contained and there are no external directories or files that have been loaded into the container.

In development, however, this can be a problem because of file permissions and ownership. The user in your environment almost certainly has a different user ID (UID) and group ID (GID) than the `www-data` user within the container. If you want to try to modify files, as `www-data` but the files are owned by a user with the UID of `1000`, you're going to run into some issues.

Luckily, we can remap a user and group ID in the container to the ID of a user that is running the container. We want to take the IDs for our user in the host environment (e.g. Ubuntu 16.04) and map those IDs to the `www-data` IDs within the container when it starts.

In order to discover your user and group ID run the following:

```
$ id -u $whoami
1000             # The UID you want to use in the .env file
$ id -g $whoami
1000             # The GID you want to use in the .env file
```

Once you have the UID and GID you should create a `.env` file with (at a bare minimum) the following contents:

```
# file: .env
GRAV_WWW_DATA_UID=1000
GRAV_WWW_DATA_GID=1000
```

Replacing the values of the `GRAV_WWW_DATA_UID` and `GRAV_WWW_DATA_GID` with the UID and GID values returned when you ran the earlier `id` commands.

If you've remapped your user correctly when you run an `ls -al` command on the Grav application directory, you should see something like this, where all directories (save the parent) are owned by `www-data`, including `user/` assuming you've mounted the directory:


```
/ # ls -al /srv/www/grav/
total 328
drwxr-xr-x   23 www-data www-data      4096 Jun  9 14:05 .
drwxr-xr-x    4 root     root          4096 Jun  9 14:05 ..
-rw-r--r--    1 www-data www-data      3046 Jun  9 13:51 .htaccess
-rw-r--r--    1 www-data www-data    104577 Jun  9 13:51 CHANGELOG.md
-rw-r--r--    1 www-data www-data      3216 Jun  9 13:51 CODE_OF_CONDUCT.md
-rw-r--r--    1 www-data www-data      7081 Jun  9 13:51 CONTRIBUTING.md
-rw-r--r--    1 www-data www-data      1071 Jun  9 13:51 LICENSE.txt
-rw-r--r--    1 www-data www-data     14973 Jun  9 13:51 README.md
drwxr-xr-x    2 www-data www-data      4096 Jun  9 14:05 assets
drwxr-xr-x    2 www-data www-data      4096 Jun  9 14:05 backup
drwxr-xr-x    2 www-data www-data      4096 Jun  9 14:05 bin
drwxr-xr-x    7 www-data www-data      4096 Jun  9 14:06 cache
-rw-r--r--    1 www-data www-data      2290 Jun  9 13:51 composer.json
-rw-r--r--    1 www-data www-data    127136 Jun  9 13:51 composer.lock
drwxr-xr-x    2 www-data www-data      4096 Jun  9 14:05 images
-rw-r--r--    1 www-data www-data      1545 Jun  9 13:51 index.php
drwxr-xr-x    2 www-data www-data      4096 Jun  9 14:05 logs
-rw-r--r--    1 www-data www-data       197 Jun  9 13:51 robots.txt
drwxr-xr-x   18 www-data www-data      4096 Jun  9 14:05 system
drwxr-xr-x    2 www-data www-data      4096 Jun  9 14:05 tmp
drwxr-xr-x    1 www-data www-data       256 May  4 13:53 user
drwxr-xr-x   42 www-data www-data      4096 Jun  9 14:05 vendor
drwxr-xr-x    2 www-data www-data      4096 Jun  9 14:05 webserver-configs
```