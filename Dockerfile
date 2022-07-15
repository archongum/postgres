FROM debian:bullseye-slim as builder

COPY ./* /workdir
WORKDIR /workdir

RUN apt-get update \
  && apt-get install -y build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev libxml2-utils xsltproc \
  && ./configure --with-blocksize=32 --with-wal-blocksize=32 \
  && make && make world-bin && make install-world-bin \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf ./* /var/lib/apt/lists/*

FROM debian:bullseye-slim
COPY --from=builder /usr/local/pgsql /usr/local/

ENV PATH $PATH:/usr/local/pgsql/bin
ENV PG_MAJOR 14
ENV PG_VERSION 14.4-1.pgdg110+1

# explicitly set user/group IDs
RUN set -eux; \
	groupadd -r postgres --gid=999; \
# https://salsa.debian.org/postgresql/postgresql-common/blob/997d842ee744687d99a2b2d95c1083a2615c79e8/debian/postgresql-common.postinst#L32-35
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
# also create the postgres user's home directory with appropriate permissions
# see https://github.com/docker-library/postgres/issues/274
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql
  

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql
ENV PGDATA /var/lib/postgresql/data

RUN mkdir /docker-entrypoint-initdb.d

ENTRYPOINT ["docker-entrypoint.sh"]

STOPSIGNAL SIGINT

EXPOSE 5432
