FROM debian:buster-slim

RUN apt-get update && apt-get install -y wget curl vim git
    
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
    LATEST=no               \
    

RUN /usr/local/bin/automysqlbackup \
    /usr/local/bin/start.sh
    
WORKDIR /backup