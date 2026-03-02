FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends supervisor curl && rm -rf /var/lib/apt/lists/*

# simt-emlite profile downloader
ARG SIMT_EMLITE_VERSION=1.2.5
RUN pip install --no-cache-dir simt-emlite==${SIMT_EMLITE_VERSION}

# Supercronic

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.43/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=f97b92132b61a8f827c3faf67106dc0e4467ccf2

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

RUN mkdir -p /supercronic
COPY crontab /supercronic/crontab

# Syncthing

ARG SYNCTHING_VERSION=2.0.14
ARG SYNCTHING_TAR=syncthing-linux-amd64-v${SYNCTHING_VERSION}
ARG SYNCTHING_URL=https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/${SYNCTHING_TAR}.tar.gz
ARG SYNCTHING_BIN=/usr/local/bin/syncthing

RUN curl -fsSLO "$SYNCTHING_URL" \
 && tar xf "${SYNCTHING_TAR}.tar.gz" \
 && mv "${SYNCTHING_TAR}/syncthing" "$SYNCTHING_BIN" \
 && chmod +x "$SYNCTHING_BIN" \
 && rm -rf "${SYNCTHING_TAR}.tar.gz" "${SYNCTHING_TAR}"

EXPOSE 21027/udp
EXPOSE 22000/udp
EXPOSE 22000/tcp

ENV PUID=1000 PGID=1000 HOME=/var/syncthing

# Profile download config files
COPY config.daily-hmce.properties /app/config/
COPY config.daily-wlce.properties /app/config/

# Supervisor

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
