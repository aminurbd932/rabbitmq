FROM mysql:8.0
COPY custom.cnf /etc/mysql/conf.d/custom.cnf
COPY user.sql /docker-entrypoint-initdb.d/user.sql
