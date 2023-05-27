#!/bin/sh

echo 'Starting up Tailscale...'

/app/tailscaled --verbose=1 --port 41641 --tun=userspace-networking --socks5-server=localhost:3215 &
sleep 5
if [ ! -S /var/run/tailscale/tailscaled.sock ]; then
    echo "tailscaled.sock does not exist. exit!"
    exit 1
fi

until /app/tailscale up \
    --authkey=${TAILSCALE_AUTH_KEY} \
    --hostname=tornode \
    --advertise-exit-node \
    --accept-dns=false \
    --ssh
do
    sleep 0.1
done

echo 'Tailscale serve Tor proxy...'

/app/tailscale serve tcp:9051 tcp://localhost:9051

echo 'Tailscale started'

iptables -F
iptables -t nat -F


iptables -t nat -A OUTPUT -m owner --uid-owner tor -j RETURN
#iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-port 5353
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports 9040
#iptables -A OUTPUT -m owner --uid-owner tor -j ACCEPT
#iptables -A OUTPUT -d 127.0.0.0/8 -j ACCEPT
#iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -j REJECT


if [ "$1" != "" ]; then
  exec "$@"
else
  echo 'Starting up Tor...'
  mkdir -p /var/lib/tor/hidden_service
  chmod 700 /var/lib/tor/hidden_service
  chown -R tor:nogroup /var/lib/tor
  while true; do
    su -s /bin/sh -c '/usr/bin/tor -f /etc/tor/torrc --runasdaemon 0' tor
    echo "Restarting tor service"
    sleep 2s
  done
fi

