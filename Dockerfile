FROM debian:buster-slim

RUN apt-get update && apt-get install -y wget curl vim iputils-ping cron

COPY install.sh /usr/local/bin
COPY start.sh /usr/local/bin
COPY my.cnf /etc/mysql/
COPY automysqlbackup /usr/local/bin

RUN chmod +x /usr/local/bin/install.sh \
    && chmod +x /usr/local/bin/start.sh \
    && chmod +x /usr/local/bin/automysqlbackup
    #&& /usr/local/bin/install.sh
    
ENV MYSQL_USER=             \
    MYSQL_PASSWORD=         \
    MYSQL_PASSWORD_FILE=    \
    MYSQL_HOST=localhost    \
    BACKUPDIR=/var/backup   \
    DBNAMES=                \
    MDBNAMES=               \
    DBEXCLUDE=              \
    DOWEEKLY=               \
    COMMCOMP=no             \
    SOCKET=                 \
    MAX_ALLOWED_PACKET=     \
    CREATE_DATABASE=yes     \
    SEPDIR=                 \
    COMP=gzip               \
    LATEST=no
    
#CMD ["install.sh"]
ENTRYPOINT ["start.sh"]