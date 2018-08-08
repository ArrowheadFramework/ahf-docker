FROM mysql:5.7

# TODO: Use MYSQL_RANDOM_ROOT_PASSWORD=yes
# TODO: grant SELECT, UPDATE, DELETE, INSERT on arrowhead.* to '<user>';
# TODO: grant SELECT, UPDATE, DELETE, INSERT on log.* to '<user>';

ENV MYSQL_USER=ahf-user \
    MYSQL_PASSWORD=ahf-pass \
    MYSQL_ROOT_PASSWORD=temporary-ahf-pass

EXPOSE 3306

WORKDIR /ahf
COPY db_init/ /docker-entrypoint-initdb.d/
