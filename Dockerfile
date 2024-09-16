FROM alpine:3.20.3

RUN apk add curl supervisor

# Supercronic

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.32/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=7da26ce6ab48d75e97f7204554afe7c80779d4e0

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

RUN mkdir -p /supercronic
COPY crontab /supercronic/crontab

# Syncthing

ARG SYNCTHING_VERSION=1.27.12
ARG SYNCTHING_TAR=syncthing-linux-amd64-v${SYNCTHING_VERSION}
ARG SYNCTHING_URL=https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/${SYNCTHING_TAR}.tar.gz
ARG SYNCTHING_BIN=/usr/local/bin/syncthing

RUN curl -fsSLO "$SYNCTHING_URL" \
 && tar xf "${SYNCTHING_TAR}.tar.gz" \
 && mv "${SYNCTHING_TAR}/syncthing" "$SYNCTHING_BIN" \
 && chmod +x "$SYNCTHING_BIN"

EXPOSE 21027/tcp
EXPOSE 22000/udp
EXPOSE 22000/tcp

ENV PUID=1000 PGID=1000 HOME=/var/syncthing

# Supervisor

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]