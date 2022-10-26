## OS part
## -------
FROM debian:buster-slim

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

#RUN apt-get update && apt-get install -y --no-install-recommends gnupg dirmngr && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends gnupg dirmngr

# Add packages for testing
RUN apt-get install iproute2 iputils-ping net-tools vim traceroute less pwgen -y

## MYSQL part
##-----------
COPY mysql-standard-4.0.27-pc-linux-gnu-i686.tar.gz /tmp/
RUN tar -xzf /tmp/mysql-standard-4.0.27-pc-linux-gnu-i686.tar.gz -C /tmp/ && mv /tmp/mysql-standard-4.0.27-pc-linux-gnu-i686 /usr/local/mysql

ENV PATH /usr/local/mysql/bin:$PATH

VOLUME /usr/local/mysql/

ADD  my.cnf /etc/

COPY entrypoint.sh /usr/local/bin/

EXPOSE 3306

ENTRYPOINT ["entrypoint.sh"]
CMD ["mysqld_safe", "--user=mysql"]