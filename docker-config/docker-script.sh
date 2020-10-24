#!/bin/bash
cat "Bienvenue!"



if [ $LOG_STDERR ]; then
    /bin/ln -sf /dev/stderr /var/log/apache2/error.log
else
	LOG_STDERR='No.'
fi

if [ $ALLOW_OVERRIDE == 'All' ]; then
    /bin/sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf
fi

if [ $LOG_LEVEL != 'warn' ]; then
    /bin/sed -i "s/LogLevel\ warn/LogLevel\ ${LOG_LEVEL}/g" /etc/apache2/apache2.conf
fi

echo "ServerName localhost" >> /etc/apache2/apache2.conf

# enable php short tags:
/bin/sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php5/apache2/php.ini

# stdout server info:
if [ ! $LOG_STDOUT ]; then
cat << EOB

    **********************************************
    *                                            *
    *    Docker image: fauria/lamp               *
    *    https://github.com/fauria/docker-lamp   *
    *                                            *
    **********************************************
    SERVER SETTINGS
    ---------------
    · Redirect Apache access_log to STDOUT [LOG_STDOUT]: No.
    · Redirect Apache error_log to STDERR [LOG_STDERR]: $LOG_STDERR
    · Log Level [LOG_LEVEL]: $LOG_LEVEL
    · Allow override [ALLOW_OVERRIDE]: $ALLOW_OVERRIDE
    · PHP date timezone [DATE_TIMEZONE]: $DATE_TIMEZONE
EOB
else
    /bin/ln -sf /dev/stdout /var/log/apache2/access.log
fi

# Set PHP timezone
/bin/sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ ${DATE_TIMEZONE}/" /etc/php5/apache2/php.ini
/bin/sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ ${DATE_TIMEZONE}/" /etc/php5/cli/php.ini
# Set PHP timezone
/bin/sed -i "s#;sendmail_path =#sendmail_path = /usr/sbin/sendmail -t -i#g" /etc/php5/apache2/php.ini
/bin/sed -i "s#;sendmail_path =#sendmail_path = /usr/sbin/sendmail -t -i#g" /etc/php5/cli/php.ini

# Run Postfix
/usr/sbin/postfix start

# Run MariaDB
#/usr/bin/mysqld_safe --timezone=${DATE_TIMEZONE}&


#create virtualhost
/usr/bin/virtualhost create ${PROJECT_VNAME} ${PROJECT_WWW} ${FUEL_ENV}

# Run Apache:
if [ $LOG_LEVEL == 'debug' ]; then
    /usr/sbin/apachectl -DFOREGROUND -k start -e debug
else
    &>/dev/null /usr/sbin/apachectl -DFOREGROUND -k start
fi

# set host in hosts
hostname >> /etc/mail/relay-domains
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf

#remove localhost limit
sed -i -e "s/Port=smtp,Addr=127.0.0.1, Name=MTA/Port=smtp, Name=MTA/g" \
    /etc/mail/sendmail.mc


/etc/init.d/apache2 restart
/etc/init.d/sendmail restart

sendmail -bd

exec "$@"