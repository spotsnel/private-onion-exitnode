ARG TSVERSION=1.40.1
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
      /var/tmp/*

RUN sed "1s/^/TransPort 127.0.0.1:9040\nDNSPort 127.0.0.1:5353\nControlPort 127.0.0.1:9051\n/" /etc/tor/torrc.sample > /etc/tor/torrc \
    &&  sed -i "s|#%include /etc/torrc.d/\*.conf|%include /etc/torrc.d/\*.conf|g" /etc/tor/torrc \
    &&  mkdir -p /etc/torrc.d

VOLUME ["/etc/torrc.d"]
VOLUME ["/var/lib/tor"]

COPY start.sh /app/start.sh
COPY dns.sh   /app/dns.sh
COPY --from=build /app/tailscaled /app/tailscaled
COPY --from=build /app/tailscale /app/tailscale

ENTRYPOINT ["/app/start.sh"]

