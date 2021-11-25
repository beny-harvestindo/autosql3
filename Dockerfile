FROM debian:buster-slim

RUN apt-get update && apt-get install -y wget curl vim git
    
RUN cd /home \
    wget https://raw.githubusercontent.com/beny-harvestindo/autosql3/master/install.sh \
    chmod +x /home/install.sh \
    /home/install.sh
    
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
    
CMD ["install.sh"]