#Apache version
FROM debian:jessie

MAINTAINER Aymen AMAIRIA <testmail@test.test>
USER root
WORKDIR /var/www/html/webapp

#Define ENV VARIABLES
ENV LOG_STDOUT FALSE
ENV LOG_STDERR FAlSE
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive

#Configuration
COPY docker-config/debconf.selections /tmp/
COPY docker-config/docker-script.sh /usr/bin/
COPY docker-config/virtualhost/virtualhost.sh /usr/bin/virtualhost
COPY docker-config/virtualhost/locale/fr/virtualhost.mo /usr/share/locale/fr/LC_MESSAGES/
COPY docker-config/virtualhost/ssl/server.crt /etc/apache2/ssl/server.crt
COPY docker-config/virtualhost/ssl/server.key /etc/apache2/ssl/server.key
# Install PHP XDEBUG configuration, (see https://blog.eleven-labs.com/fr/debugger-avec-xdebug/)
COPY docker-config/xdebug.ini /etc/php5/apache2/conf.d/
COPY docker-config/xdebug.ini /etc/php5/cli/conf.d/

RUN debconf-set-selections /tmp/debconf.selections

#Installation des packets
RUN apt-get update && apt-get -y upgrade && apt-get -y install 	wget \
																apt-transport-https \
																ca-certificates \
																curl \
																lsb-release \
																ca-certificates \
																software-properties-common \
																gnupg \
																apache2 \
																libapache2-mod-php5 \
																vim \
																nano \
																zip \
																unzip \
																dos2unix \
																git \
																nodejs \
																npm \
																tree \
																curl \
																ftp \
																locales \
																libfontconfig1 \
																libxrender1 \
																sendmail \
																sendmail-cf \
																m4
RUN apt-get install -y \
	php5 \
	php5-cgi \
	php5-cli \
	php5-common \
	php5-curl \
	php5-dev \
	php5-enchant \
	php5-fpm \
	php5-gd \
	php5-gmp \
	php5-imap \
	php5-interbase \
	php5-intl \
	php5-json \
	php5-ldap \
	php5-mcrypt \
	php5-mysql \
	php5-odbc \
	php5-pgsql \
	php5-phpdbg \
	php5-pspell \
	php5-readline \
	php5-recode \
	php5-sybase \
	php5-tidy \
	php5-xmlrpc \
	php5-xsl \
	php5-xdebug \
	php-tcpdf \
	php-soap
#Ajout Authentification via Kerberos
RUN apt-get update && apt-get -y upgrade && apt-get -y install  krb5-kdc \
                                                                krb5-admin-server \
                                                                krb5-user \
                                                                libpam-krb5 \
#                                                                libkrb5-dev \
                                                                libpam-ccreds \
                                                                libapache2-mod-auth-kerb \
                                                                realmd \
                                                                heimdal-dev \
                                                                make

#RUN apt-get update && apt-get -y upgrade && apt-get -y install  krb5_newrealm

COPY docker-config/kerberos/dev/krb5.conf /etc/krb5.conf
COPY docker-config/kerberos/dev/krb5dev.keytab /etc/krb5dev.keytab

######### Nettoyer le gestionnaire de paquet
RUN apt-get autoclean && apt-get -y autoremove
#Composer
#RUN curl -sS https://getcomposer.org/installer | php
#RUN mv composer.phar /usr/local/bin/composer
##PHPUnit
#RUN wget https://phar.phpunit.de/phpunit-6.5.phar
#RUN chmod +x phpunit-6.5.phar
#RUN mv phpunit-6.5.phar /usr/local/bin/phpunit

RUN a2enmod rewrite
RUN a2enmod ssl
## Set LOCALE to UTF8
#
RUN echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen fr_FR.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=fr_FR.UTF-8
ENV LC_ALL fr_FR.UTF-8

RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN chmod +x /usr/bin/docker-script.sh
RUN chmod +x /usr/bin/virtualhost
#RUN chmod +x /usr/local/bin/composer

RUN sed -i -e 's/\r$//' /usr/bin/docker-script.sh
RUN sed -i -e 's/\r$//' /usr/bin/virtualhost
RUN export TERM=xterm
RUN chmod -R 777 /var/www/html/
RUN chown -R www-data:www-data /var/www/html/

#POSTFIX
#    RUN groupadd -g 124 postfix && \
#        groupadd -g 125 postdrop && \
#    useradd -u 116 -g 124 postfix
#
#    RUN apt-get update && \
#      DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
#        postfix \
#        bsd-mailx
#
#    CMD echo test aymen mail | mail testmail@test.test

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/bin/docker-script.sh"]
CMD ["true"]