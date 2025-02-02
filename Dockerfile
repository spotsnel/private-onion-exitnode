ARG TSVERSION=1.80.0
ARG TSFILE=tailscale_${TSVERSION}_amd64.tgz

FROM alpine:latest as build
ARG TSFILE
WORKDIR /app

RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
  tar xzf ${TSFILE} --strip-components=1


FROM alpine:3.18

RUN apk --no-cache add \
      tor \
      torsocks \
      iptables \
      curl \
    && rm -rf /var/cache/apk/* \
      /tmp/* \
      /var/tmp/* \
    && mkdir -p /etc/torrc.d

VOLUME ["/etc/torrc.d"]
VOLUME ["/var/lib/tor"]

COPY torrc    /etc/tor/torrc
COPY start.sh /app/start.sh
COPY dns.sh   /app/dns.sh
COPY --from=build /app/tailscaled /app/tailscaled
COPY --from=build /app/tailscale /app/tailscale

ENTRYPOINT ["/app/start.sh"]

