FROM ubuntu:24.04

ENV OS_LOCALE="en_US.UTF-8"

RUN apt-get update && apt-get install -y locales && locale-gen ${OS_LOCALE}

ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_ALLOW_SUPERUSER=1 \
    LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE}

RUN apt-get update -y && apt-get upgrade -y 

RUN apt-get install -y software-properties-common ca-certificates lsb-release apt-transport-https \
    && add-apt-repository ppa:ondrej/php 

RUN apt-get update -y && apt install -y curl \
    php8.3 php8.3-cli php8.3-curl php8.3-apcu php8.3-dev libmcrypt-dev php-pear php8.3-pdo-mysql \
    php8.3-mbstring php8.3-opcache php8.3-readline php8.3-zip php8.3-bcmath php8.3-gd php8.3-mysql \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer clear-cache \
    && apt-get install -y gettext-base \
    && apt-get clean  \
    && apt-get update -y && apt-get install -y libsodium-dev php8.3-bz2 php8.3-soap php8.3-dba php8.3-gmp \
    php8.3-intl php8.3-ldap php8.3-odbc php8.3-pdo-dblib unixodbc unixodbc-dev php8.3-pdo-odbc php8.3-sqlite3 \
    php8.3-xmlrpc php8.3-common php8.3-uuid php8.3-amqp php8.3-memcached php8.3-pdo-sqlite php8.3-mongodb \
    && apt-get update \
    && apt-get install -y supervisor \
    && mkdir -p /var/log/supervisor

RUN echo "memory_limit=512M" >> /etc/php/8.3/apache2/conf.d/1-myconfig.ini \
    && echo "upload_max_filesize=500M" >> /etc/php/8.3/apache2/conf.d/1-myconfig.ini \
    && echo "max_file_uploads=1000" >> /etc/php/8.3/apache2/conf.d/1-myconfig.ini \
    && echo "post_max_size=500M" >> /etc/php/8.3/apache2/conf.d/1-myconfig.ini \
    && echo "max_execution_time=600" >> /etc/php/8.3/apache2/conf.d/1-myconfig.ini \
    && echo "disable_functions=getmyuid,passthru,leak,listen,diskfreespace,tmpfile,link,ignore_user_abort,shell_exec,dl,set_time_limit,exec,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server" >> /etc/php/8.3/apache2/conf.d/1-myconfig.ini \
    && echo "allow_url_fopen = On" >> /etc/php/8.3/apache2/conf.d/1-myconfig.ini \
    && echo "error_reporting = E_ALL & ~E_NOTICE" >> /etc/php/8.3/apache2/conf.d/1-myconfig.ini

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer \
    && rm /var/www/html/index.html

COPY .conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY .conf/supervisord.conf  /etc/supervisor/conf.d/supervisord.conf
WORKDIR /var/www/html 
RUN a2enmod rewrite
EXPOSE 80
CMD ["/usr/bin/supervisord"]

