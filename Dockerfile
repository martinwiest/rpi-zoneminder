FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ Europe/Berlin
ENV ZM_DB_HOST 127.0.0.1
ENV ZM_DB_NAME zm
ENV ZM_DB_USER zmuser
ENV ZM_DB_PASS zmpass
ENV ZM_DB_PORT 3306
ENV PHPVERSION="7.4"

RUN apt-get update && apt-get install -y -q --no-install-recommends \
        apt-transport-https gnupg ca-certificates wget \
        && wget -O - https://zmrepo.zoneminder.com/debian/archive-keyring.gpg | apt-key add - && \
        apt install -y software-properties-common && add-apt-repository ppa:iconnor/zoneminder-1.36 && \
        apt-get update && apt-get install -y -q --no-install-recommends \
        tzdata apache2 php libapache2-mod-php php-mysql zoneminder vlc-plugin-base && \
	apt-get autoremove && rm -rf /var/lib/apt/lists/* 

RUN chmod 740 /etc/zm/zm.conf \
        && chown root:www-data /etc/zm/zm.conf \
        && chown -R www-data:www-data /var/cache/zoneminder/

RUN a2enmod cgi rewrite && a2enconf zoneminder && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    echo "date.timezone = $TZ" >> /etc/php/$PHPVERSION/apache2/php.ini

RUN mkdir -p /var/log/zm ; sync
COPY startup.sh /sbin/startup.sh
RUN chmod +x /sbin/startup.sh

VOLUME /var/cache/zoneminder /etc/zm /var/log/zm

EXPOSE 80 9000 6802

CMD ["/sbin/startup.sh"]
