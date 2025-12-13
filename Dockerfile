# syntax=docker/dockerfile:1

###############################################################################
# GLOBAL BUILD ARGS
###############################################################################

ARG LUANTI_VERSION=5.14.0
ARG LUANTI_SHA256="b9f561fa37db3c7ea1b8ba15cfede8282b7a79b9e939b0357269c8b037cf5aea"
ARG MINETEST_GAME_VERSION=5.8.0
ARG MINETEST_GAME_SHA256="33a3bb43b08497a0bdb2f49f140a2829e582d5c16c0ad52be1595c803f706912"

ARG CFLAGS="-flto -Wimplicit -Wno-cast-function-type"
ARG CXXFLAGS="$CFLAGS"
ARG LDFLAGS="-flto -Wl,--gc-sections"

ARG ALPINE_VERSION=edge
ARG LUAROCKS_VERSION=3.12.2

###############################################################################
# FETCH: download Luanti source
###############################################################################
FROM alpine:${ALPINE_VERSION} AS fetch

ARG LUANTI_VERSION
ARG LUANTI_SHA256
ARG MINETEST_GAME_VERSION
ARG MINETEST_GAME_SHA256

RUN apk add --no-cache wget tar ca-certificates

WORKDIR /build

RUN set -eux; \
    wget -O luanti.tar.gz "https://github.com/luanti-org/luanti/archive/refs/tags/${LUANTI_VERSION}.tar.gz"; \
    if [ -n "${LUANTI_SHA256}" ]; then \
      echo "${LUANTI_SHA256}  luanti.tar.gz" | sha256sum -c -; \
    fi; \
    mkdir luanti && \
    tar xzf luanti.tar.gz -C luanti --strip-components=1

RUN set -eux; \
    wget -O minetest_game.tar.gz "https://github.com/luanti-org/minetest_game/archive/refs/tags/${MINETEST_GAME_VERSION}.tar.gz"; \
    if [ -n "${MINETEST_GAME_SHA256}" ]; then \
      echo "${MINETEST_GAME_SHA256}  minetest_game.tar.gz" | sha256sum -c -; \
    fi; \
    mkdir minetest_game && \
    tar xzf minetest_game.tar.gz -C minetest_game --strip-components=1

###############################################################################
# BUILD DEPS: toolchain + libs + minimal passwd/group
###############################################################################
FROM alpine:${ALPINE_VERSION} AS build-deps

ARG LUANTI_VERSION
ARG LUAROCKS_VERSION
ARG CFLAGS
ARG CXXFLAGS
ARG LDFLAGS

# You were already on edge/testing for nginx; same idea here.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache \
      build-base \
      cmake \
      ninja \
      git \
      pkgconfig \
      linux-headers \
      libaio-dev \
      luajit-dev \
      lua5.4-dev \
      jsoncpp-dev \
      curl \
      unzip \
      curl-dev \
      bzip2-dev \
      gmp-dev \
      libspatialindex-dev \
      zlib-dev \
      libpng-dev \
      libjpeg-turbo-dev \
      ncurses-dev \
      gettext-dev \
      sqlite-dev \
      leveldb-dev \
      postgresql-dev \
      hiredis-dev \
      icu-dev \
      ca-certificates

WORKDIR /build

COPY --from=fetch /build/luanti ./luanti

# Minimal passwd/group, luanti user = uid/gid 101
RUN echo 'luanti:x:101:101:luanti:/world:/sbin/nologin' > /luanti.passwd && \
    echo 'luanti:x:101:' > /luanti.group

# Common env used by all build stages
ENV PREFIX=/opt/luanti \
    CC="gcc" \
    CXX="g++" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" 

###############################################################################
# BASE CMAKE CONFIG FLAGS (server-only, no client, no sound, etc.)
###############################################################################
FROM build-deps AS build-base-config

ENV CMAKE_COMMON_FLAGS="\
  -DBUILD_CLIENT=FALSE \
  -DBUILD_SERVER=TRUE \
  -DBUILD_UNITTESTS=FALSE \
  -DBUILD_BENCHMARKS=FALSE \
  -DCMAKE_BUILD_TYPE=Release \
  -DRUN_IN_PLACE=FALSE \
  -DENABLE_SOUND=OFF \
  -DENABLE_GLES=OFF \
  -DENABLE_GETTEXT=ON \
  -DENABLE_CURSES=ON \
  -DENABLE_LUAJIT=ON \
  -DENABLE_PROMETHEUS=OFF \
  -DENABLE_SYSTEM_GMP=ON \
  -DENABLE_SYSTEM_JSONCPP=ON \
  -DENABLE_SPATIAL=ON \
  -DVERSION_EXTRA='Adravox' \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_C_FLAGS=${CFLAGS} \
  -DCMAKE_CXX_FLAGS=${CXXFLAGS} \
  -DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS} \
  -DCMAKE_CXX_STANDARD_LIBRARIES='-lintl' \
"

###############################################################################
# BUILD: SQLite backend
###############################################################################
FROM build-base-config AS build-sqlite

WORKDIR /build/build-sqlite

RUN cmake ../luanti \
      ${CMAKE_COMMON_FLAGS} \
      -DENABLE_SQLITE=ON \
      -DENABLE_LEVELDB=OFF \
      -DENABLE_POSTGRESQL=OFF \
      -DENABLE_REDIS=OFF \
  && cmake --build . --target install \
  && strip --strip-unneeded ${PREFIX}/bin/luantiserver

###############################################################################
# BUILD: LevelDB backend
###############################################################################
FROM build-base-config AS build-leveldb

WORKDIR /build/build-leveldb

RUN cmake ../luanti \
      ${CMAKE_COMMON_FLAGS} \
      -DENABLE_SQLITE=ON \
      -DENABLE_LEVELDB=ON \
      -DENABLE_POSTGRESQL=OFF \
      -DENABLE_REDIS=OFF \
  && cmake --build . --target install \
  && strip --strip-unneeded ${PREFIX}/bin/luantiserver || true

###############################################################################
# BUILD: PostgreSQL backend
###############################################################################
FROM build-base-config AS build-postgres

WORKDIR /build/build-postgres

RUN cmake ../luanti \
      ${CMAKE_COMMON_FLAGS} \
      -DENABLE_SQLITE=ON \
      -DENABLE_LEVELDB=OFF \
      -DENABLE_POSTGRESQL=ON \
      -DENABLE_REDIS=OFF \
  && cmake --build . --target install \
  && strip --strip-unneeded ${PREFIX}/bin/luantiserver || true

###############################################################################
# BUILD: Redis backend
###############################################################################
FROM build-base-config AS build-redis

WORKDIR /build/build-redis

RUN cmake ../luanti \
      ${CMAKE_COMMON_FLAGS} \
      -DENABLE_SQLITE=ON \
      -DENABLE_LEVELDB=OFF \
      -DENABLE_POSTGRESQL=OFF \
      -DENABLE_REDIS=ON \
  && cmake --build . --target install \
  && strip --strip-unneeded ${PREFIX}/bin/luantiserver || true

###############################################################################
# RUNTIME BASE: luanti user + dirs + tiny Alpine
###############################################################################
FROM alpine:${ALPINE_VERSION} AS luanti-user

ARG LUANTI_VERSION
ARG IMAGE_SOURCE=""
ARG VCS_REF=""

LABEL maintainer="James Dornan <james@catch22.com>" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.version="${LUANTI_VERSION}"

# Runtime libs common across all backends
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache \
      ca-certificates \
      luajit \
      jsoncpp \
      gmp \
      bzip2 \
      libaio \
      libspatialindex \
      sqlite-libs \
      ncurses-libs \
      libintl \
      libcurl \
      zlib \
      zstd \
      libstdc++ \
      su-exec \
      tmux \
      luarocks5.1 \
      tzdata

# Bring in passwd/group for uid/gid 101
COPY --from=build-deps /luanti.passwd /etc/passwd
COPY --from=build-deps /luanti.group /etc/group

# Config + world layout
RUN mkdir -p /etc/luanti /world /opt/luanti/tools /var/lib/luanti && \
    chown -R luanti:luanti /etc/luanti /world /var/lib/luanti

ENV PREFIX=/opt/luanti
ENV PATH="${PREFIX}/bin:${PATH}"

# Install Minetest Game into the Luanti prefix
RUN mkdir -p ${PREFIX}/share/luanti/games/minetest
COPY --from=fetch /build/minetest_game/ ${PREFIX}/share/luanti/games/minetest/

# Core world/server env defaults
ENV WORLD_DIR=/world \
    BACKEND=sqlite3 \
    WORLD_NAME="Adravox World" \
    GAMEID=minetest

# Optional backend overrides
ENV PLAYER_BACKEND= \
    AUTH_BACKEND= \
    MOD_STORAGE_BACKEND= \
    READONLY_BACKEND=

# Optional world flags
ENV ENABLE_DAMAGE= \
    CREATIVE_MODE= \
    SERVER_ANNOUNCE= \
    SEED= \
    MG_NAME=

# PostgreSQL wiring (no secrets here)
ENV PG_SERVICE= \
    PG_HOST=db \
    PG_PORT=5432 \
    PG_DB=luanti \
    PG_USER=luanti \
    PG_SSLMODE=disable

# Redis wiring
ENV REDIS_ADDRESS= \
    REDIS_HASH= \
    REDIS_PORT= \
    REDIS_PASSWORD=

# Lua bootstrap + entrypoint
COPY tools/bootstrap /opt/luanti/tools/bootstrap
COPY entrypoint /entrypoint

WORKDIR /world

EXPOSE 30000/udp

ENTRYPOINT ["/entrypoint"]

###############################################################################
# FINAL: SQLite runtime
###############################################################################
FROM luanti-user AS luanti-sqlite

# Bring in Luanti (sqlite-enabled) binary
COPY --from=build-sqlite ${PREFIX} ${PREFIX}

RUN apk add lua5.1-sql-sqlite3
# Optional: sanity-check at build time
RUN luajit -e 'local ok, err = pcall(function() require("luasql.sqlite3") end); if not ok then error(err) end'

###############################################################################
# FINAL: LevelDB runtime
###############################################################################
FROM luanti-user AS luanti-leveldb

RUN apk add --no-cache leveldb

COPY --from=build-leveldb ${PREFIX} ${PREFIX}

###############################################################################
# FINAL: PostgreSQL runtime
###############################################################################
FROM luanti-user AS luanti-postgres

RUN apk add --no-cache postgresql-libs

# Bring in Luanti (postgres-enabled) binary
COPY --from=build-postgres ${PREFIX} ${PREFIX}

RUN apk add lua5.1-sql-postgres
# Optional: sanity-check at build time
RUN luajit -e 'local ok, err = pcall(function() require("luasql.postgres") end); if not ok then error(err) end'

###############################################################################
# FINAL: Redis runtime
###############################################################################
FROM luanti-user AS luanti-redis

RUN apk add --no-cache hiredis

COPY --from=build-redis ${PREFIX} ${PREFIX}
