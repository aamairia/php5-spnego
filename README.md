#SPNEGO PHP 5 APACHE2 KERBEROS V5 GSS

    1) extraire l'archive /extension/php-spnego-ext.rar dans le dossier dossier extension
    2) se positionner sous le dossier extension/php-spnego-ext/
    3) Installer l'extension comme suit
# install this php extension
    sudo apt-get install php5-dev heimdal-dev make
    phpize
    ./configure
    make
    sudo make install
    sudo vi /etc/php5/conf.d/krb5.ini
    extension=krb5.so


