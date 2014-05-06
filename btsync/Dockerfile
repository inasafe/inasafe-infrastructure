FROM debian:stable

MAINTAINER Werner Macho <werner@linfiniti.com>

RUN apt-get update && apt-get install -y curl
RUN curl -o /usr/bin/btsync.tar.gz http://download-lb.utorrent.com/endpoint/btsync/os/linux-x64/track/stable
RUN cd /usr/bin && tar -xzvf btsync.tar.gz && rm btsync.tar.gz

ADD start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 55555

CMD /start.sh
