# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE_REGISTRY=ghcr.io
ARG BASE_IMAGE_NAME=linuxserver/baseimage-alpine
ARG BASE_IMAGE_VARIANT=3.22
ARG BASE_IMAGE=${BASE_IMAGE_REGISTRY}/${BASE_IMAGE_NAME}:${BASE_IMAGE_VARIANT}
ARG BUILD_OUTPUT_DIR=/out
ARG TAR1090_DB_URL=https://github.com/wiedehopf/tar1090-db/raw/csv/aircraft.csv.gz
ARG READSB_REPO_URL=https://github.com/wiedehopf/readsb
ARG READSB_REPO_BRANCH=dev
ARG VCS_URL=https://github.com/blackoutsecure/docker-readsb

FROM ${BASE_IMAGE} AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_OUTPUT_DIR
ARG TAR1090_DB_URL
ARG READSB_REPO_URL
ARG READSB_REPO_BRANCH
ARG VCS_URL

RUN apk add --no-cache \
        build-base \
        ca-certificates \
        git \
        librtlsdr-dev \
        ncurses-dev \
        pkgconf \
        wget \
        zlib-dev \
        zstd-dev

WORKDIR /src
RUN git clone --branch ${READSB_REPO_BRANCH} --single-branch --depth 1 ${READSB_REPO_URL} . && \
    BUILD_DATE="$(git log -1 --format=%cI)" && \
    VERSION="$(cat VERSION 2>/dev/null || cat version 2>/dev/null || git describe --tags --always --dirty 2>/dev/null || echo unknown)" && \
    VCS_REF="$(git rev-parse HEAD)" && \
    printf 'BUILD_DATE=%s\nVERSION=%s\nVCS_REF=%s\nVCS_URL=%s\n' "${BUILD_DATE}" "${VERSION}" "${VCS_REF}" "${VCS_URL}" > /tmp/readsb-build-metadata.env && \
    rm -rf .git

RUN set -e && \
    MARCH="" && \
    if [ "$(uname -m)" = "x86_64" ]; then MARCH=" -march=nehalem"; fi && \
    mkdir -p "${BUILD_OUTPUT_DIR}/usr/local/bin" && \
    make -j"$(nproc)" RTLSDR=yes OPTIMIZE="-O2${MARCH}" && \
    install -D -m 0755 readsb "${BUILD_OUTPUT_DIR}/usr/local/bin/readsb" && \
    install -D -m 0755 viewadsb "${BUILD_OUTPUT_DIR}/usr/local/bin/viewadsb" && \
    make clean && \
    make -j"$(nproc)" PRINT_UUIDS=yes TRACKS_UUID=yes OPTIMIZE="-O2${MARCH}" && \
    install -D -m 0755 readsb "${BUILD_OUTPUT_DIR}/usr/local/bin/readsb-uuid" && \
    install -D -m 0755 viewadsb "${BUILD_OUTPUT_DIR}/usr/local/bin/viewadsb-uuid" && \
    strip --strip-unneeded \
        "${BUILD_OUTPUT_DIR}/usr/local/bin/"* && \
    mkdir -p "${BUILD_OUTPUT_DIR}/usr/local/share/tar1090" "${BUILD_OUTPUT_DIR}/usr/local/share/readsb" && \
    install -D -m 0644 /tmp/readsb-build-metadata.env "${BUILD_OUTPUT_DIR}/usr/local/share/readsb/build-metadata.env" && \
    wget -q --https-only --tries=3 --timeout=20 -O "${BUILD_OUTPUT_DIR}/usr/local/share/tar1090/aircraft.csv.gz" "${TAR1090_DB_URL}"

FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG READSB_USER=root
ARG READSB_RUN_DIR=/run/readsb
ARG TAR1090_DB_PATH=/usr/local/share/tar1090/aircraft.csv.gz
ARG VCS_URL

LABEL build_version="Linuxserver.io version:- unknown Build-date:- unknown"
LABEL maintainer="Blackout Secure - https://blackoutsecure.app/"
LABEL org.opencontainers.image.title="docker-readsb" \
    org.opencontainers.image.description="LinuxServer.io style containerized build of readsb, a high-performance ADS-B decoder with RTL-SDR support. Outputs JSON and network feeds, running in a hardened LinuxServer.io-based environment for reliable aircraft signal decoding." \
    org.opencontainers.image.url="${VCS_URL}" \
    org.opencontainers.image.source="${VCS_URL}" \
    org.opencontainers.image.revision="unknown" \
    org.opencontainers.image.created="unknown" \
    org.opencontainers.image.version="unknown" \
    org.opencontainers.image.licenses="GPL-3.0-or-later"

ENV HOME="/config" \
    READSB_USER="${READSB_USER}" \
    READSB_RUN_DIR="${READSB_RUN_DIR}" \
    TAR1090_DB_PATH="${TAR1090_DB_PATH}" \
    READSB_ARGS="--net --device-type rtlsdr --write-json ${READSB_RUN_DIR} --write-json-every 1 --db-file ${TAR1090_DB_PATH}"

RUN apk add --no-cache \
        librtlsdr \
        ncurses-libs \
        jemalloc \
        zlib \
        zstd \
        curl \
        jq \
        gzip

COPY --link --from=builder /out/usr/local/ /usr/local/
COPY --link root/ /

ENV LD_PRELOAD="/usr/lib/libjemalloc.so.2" \
    MALLOC_CONF="narenas:1,tcache:false"

RUN if [ -f /usr/local/share/readsb/build-metadata.env ]; then . /usr/local/share/readsb/build-metadata.env; fi && \
    echo "Linuxserver.io version:- ${VERSION:-unknown} Build-date:- ${BUILD_DATE:-unknown} Revision:- ${VCS_REF:-unknown}" > /build_version && \
    find /etc/s6-overlay/s6-rc.d -type f \( -name run -o -name finish -o -name check \) -exec chmod 0755 {} + && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 30001 30002 30003 30004 30005 30104
VOLUME ["/config"]
