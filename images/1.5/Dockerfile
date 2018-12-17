# The MIT License (MIT)
#
# Copyright (c) 2018 Extesla, LLC.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

FROM extesla/php:7.2
MAINTAINER Sean Quinn "sean.quinn@extesla.com"

#: TODO: PHP Zip extension is not installed

ENV GRAV_VERSION=1.5.6 \
    NGINX_VERSION=1.15.6 \
    NGINX_GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
    WWW_DIR=/srv/www \
    ENABLE_XDEBUG="false"

WORKDIR /

#: DEPENDENCIES
#: ============
#:
#:   .build-deps::
#:
#:   .gettext::
#:     We bring in gettext so we can get `envsubst` which we use later in the
#:     build. We don't need the rest of gettext, so we want to eventually
#:     remove all of the other files that are included. Prior to deleting the
#:     gettext package(s) we want to move `envsubst` out of /usr/bin, then
#:     delete all of the gettext dependencies (which will be removed cleanly),
#:     and then finally move `envsubst` back into `/usr/local/bin`, e.g.
#:
#:     ```
#:     $ mv /usr/bin/envsubst /tmp
#:     $ apk del .gettext
#:     $ mv /tmp/envsubst /usr/local/bin/
#:     ```
#:
RUN apk update && apk upgrade \
 && apk add --no-cache --virtual .build-deps \
    curl \
    gcc \
    geoip-dev \
    gnupg \
    libc-dev \
    libxslt-dev \
    libzip-dev \
    linux-headers \
    make \
    openssl-dev \
    pcre-dev \
    perl-dev \
    zlib-dev \
 && apk add --no-cache --virtual .gettext gettext \
 && apk add --no-cache shadow supervisor \
 && sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisord.conf \
 && sed -i 's/^\(files = .*\)$/;\1/' /etc/supervisord.conf \
 && sed -i 's/^\(\[include\]\)$/\1\nfiles = \/etc\/supervisor\/conf.d\/*.conf/' /etc/supervisord.conf \
 && mkdir -p /etc/supervisor/conf.d \
 && apk add --no-cache acl gd-dev git libzip


#: ==========================================================================
#: Install Extensions
#: ==========================================================================

#: Install Imagemagick
COPY config/etc/php/mods-available/imagick.ini /etc/php/mods-available/imagick.ini
RUN apk add --no-cache --virtual .imagemagick-deps \
    imagemagick \
    imagemagick-dev \
    imagemagick-libs \
 && pecl install imagick \
 && ln -s /etc/php/mods-available/imagick.ini /etc/php/conf.d/20-imagick.ini

#: Install XDebug
COPY config/etc/php/mods-available/xdebug.ini /etc/php/mods-available/xdebug.ini
RUN pecl install xdebug \
 && ln -s /etc/php/mods-available/xdebug.ini /etc/php/conf.d/20-xdebug.ini

#: Zip
COPY config/etc/php/mods-available/zip.ini /etc/php/mods-available/zip.ini
RUN pecl install zip \
 && ln -s /etc/php/mods-available/zip.ini /etc/php/conf.d/10-zip.ini

#: Configure PHP-FPM pools
COPY config/etc/php/php-fpm.d/www.conf /etc/php/php-fpm.d/www.conf

#: ==========================================================================
#: Composer
#: ==========================================================================

RUN curl -sS https://getcomposer.org/installer | php \
 && chmod +x composer.phar \
 && mv composer.phar /usr/local/bin/composer \
 && composer self-update

#: ==========================================================================
#: Adjust PHP Settings
#: ==========================================================================

RUN sed -i "s/^memory_limit = 128M$/memory_limit = 2048M/" /etc/php/php.ini \
 && sed -i "s/^;realpath_cache_size = 16k$/realpath_cache_size = 4096k/" /etc/php/php.ini \
 && sed -i "s/^;realpath_cache_ttl = 120$/realpath_cache_ttl = 600/" /etc/php/php.ini \
 && sed -i "s/^;date.timezone =\s*$/date.timezone = UTC/" /etc/php/php.ini \
 && sed -i "s/^(\[global\])$/$1\npid=\/var\/run\/php-fpm.pid/" /etc/php/php-fpm.conf



#: ==========================================================================
#: NGINX
#: ==========================================================================

#: NGINX
#: =====
#:   The `nginx` user is the (default) user given access to the nginx
#:   processes. This will almost always be overridden to be `www-data`,
#:   but we build and configure using this user.
#:
#:   We secure the `nginx` user by preventing logins. This is done by
#:   directing logins to the `/sbin/nologin` shell.
RUN set -x \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx


RUN CONFIG="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-debug \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_perl_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    " \
 && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
 && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
 && mkdir -p /tmp/gnupg \
 && export GNUPGHOME="$(mktemp -d -p /tmp/gnupg)" \
 && for key in $NGINX_GPG_KEYS; do \
      gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
      gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
      gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
    done \
 && gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
 && rm -rf "/tmp/gnupg" "nginx.tar.gz.asc" \
 && mkdir -p /usr/src \
 && tar -zxC /usr/src -f nginx.tar.gz \
 && rm nginx.tar.gz \
 && cd /usr/src/nginx-$NGINX_VERSION \
 && ./configure $CONFIG --with-debug \
 && make -j$(getconf _NPROCESSORS_ONLN) \
 && mv objs/nginx objs/nginx-debug \
 && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
 && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
 && mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
 && mv objs/ngx_http_perl_module.so objs/ngx_http_perl_module-debug.so \
 && mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
 && ./configure $CONFIG \
 && make -j$(getconf _NPROCESSORS_ONLN) \
 && make install \
 && rm -rf /etc/nginx/html/ \
 && mkdir -p /etc/nginx/conf.d/ \
 && mkdir -p /etc/nginx/sites/ \
 && mkdir -p /etc/nginx/sites-available/ \
 && mkdir -p /etc/nginx/sites-enabled/ \
 && mkdir -p /usr/share/nginx/html/ \
 && install -m644 html/index.html /usr/share/nginx/html/ \
 && install -m644 html/50x.html /usr/share/nginx/html/ \
 && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
 && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
 && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
 && install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
 && install -m755 objs/ngx_http_perl_module-debug.so /usr/lib/nginx/modules/ngx_http_perl_module-debug.so \
 && install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
 && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
 && strip /usr/sbin/nginx* \
 && strip /usr/lib/nginx/modules/*.so


#: RUN-TIME DEPENDENCIES
#: =====================
#:   The runtime dependencies are determined by investigating the libraries
#:   and modules installed for nginx.
#:
RUN runDeps="$( \
    scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /usr/bin/envsubst \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | sort -u \
    | xargs -r apk info --installed \
    | sort -u \
    )" \
 && apk add --no-cache --virtual .nginx-rundeps $runDeps


#: CLEAN UP
#: ========
#:   Clean up the image by removing APK packages (e.g. .build-deps, .gettext,
#:   etc.), removing source files, and moving
#:
RUN rm -rf /usr/src/nginx-$NGINX_VERSION \
 && apk del .build-deps \
 && mv /usr/bin/envsubst /tmp/ \
 && apk del .gettext \
 && mv /tmp/envsubst /usr/local/bin/ \
 && rm -rf /var/cache/apk/*


#: LOGGING
#: =======
#:   Forward request and error logs to the docker log collector.
#:
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log


#: ADD NGINX CONFIGURATION
#: =======================
COPY config/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

RUN rm -rf /etc/nginx/conf.d/default.conf \
 && mkdir -p /var/lib/nginx \
 && chown -R www-data:www-data /var/lib/nginx

#: MODIFY SUPERVISOR CONFIGURATION
#: ===============================
RUN sed -i 's/^loglevel=info/loglevel=debug/' /etc/supervisord.conf
COPY config/etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
COPY config/etc/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf

#: CONFIGURATION
#: =============
#:   Overwrite and add new configuration to the server.
#:
COPY config/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/etc/nginx/conf.d/file.conf /etc/nginx/conf.d/file.conf
COPY config/etc/nginx/conf.d/gzip.conf /etc/nginx/conf.d/gzip.conf
COPY config/etc/nginx/conf.d/php-fpm.conf /etc/nginx/conf.d/php-fpm.conf
COPY config/etc/nginx/conf.d/requests.conf /etc/nginx/conf.d/requests.conf
COPY config/etc/nginx/sites/grav /etc/nginx/sites/grav

RUN rm -rf /etc/nginx/conf.d/default.conf \
 && mkdir -p /var/lib/nginx && chown -R www-data:www-data /var/lib/nginx \
 && mkdir -p /var/cache/www && chown -R www-data:www-data /var/cache/www \
 && mkdir -p /var/log/www && chown -R www-data:www-data /var/log/www


#: ==========================================================================
#: GRAV
#: ==========================================================================

RUN mkdir -p $WWW_DIR \
 && curl -L0 https://getgrav.org/download/core/grav-admin/$GRAV_VERSION -o grav.zip \
 && mkdir -p /tmp/grav \
 && unzip grav.zip -d /tmp/grav \
 && mv /tmp/grav/grav-admin $WWW_DIR/grav \
 && chown -R www-data:www-data $WWW_DIR/grav \
 && rm -rf /tmp/grav grav.zip

#: MOUNT POINTS
#: ============
#:   Defines the various volumes that can be mounted
#:
#:     /etc/nginx/sites::
#:       The site data that can be made available to nginx. If you have a
#:       multiple websites, but not all are available you might create the
#:       necessary directory structure for their configuration here, e.g.:
#:
#:         /etc/nginx/sites/acme.com
#:         /etc/nginx/sites/example.com
#:         ...
#:
#:       You can then symlink the ones that should be available (but not
#:       necessarily enabled) to /etc/nginx/sites-available.
#:
#:     /etc/nginx/sites-available::
#:       The sites that should be (automatically) enabled.
#:
VOLUME /etc/nginx/sites
VOLUME /etc/nginx/sites-available
VOLUME /srv/www/grav/user
EXPOSE 80 443

#: DOCKER ENTRYPOINT
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-c", "/etc/supervisord.conf"]
