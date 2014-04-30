FROM debian:stable

MAINTAINER Werner Macho <werner@linfiniti.com>

RUN apt-get update

RUN apt-get -y install apache2

ENV APACHE_RUN_USER    www-data
ENV APACHE_RUN_GROUP   www-data
ENV APACHE_PID_FILE    /var/run/apache2.pid
ENV APACHE_RUN_DIR     /var/run/apache2
ENV APACHE_LOCK_DIR    /var/lock/apache2
ENV APACHE_LOG_DIR     /var/log/apache2
ENV LANG               C

ADD config/inasafe-data.conf /etc/apache2/sites-available/inasafe-data.conf
RUN a2dissite 000-default
RUN a2ensite inasafe-data.conf

EXPOSE 80

ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-D", "FOREGROUND"]
