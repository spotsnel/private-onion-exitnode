Onion Services via Tailscale ExitNode
=====================================

![](./assets/StandWithUkraine.svg)

Private exitnode to open Onion Services via Tailscale IPN

    Work in Progress
    Experimental


## Usage 

Build:
```
$ podman build -t tornode -f Dockerfile .
```

Run the container as follows:
```
$ modprobe iptable_nat
$ podman run -d --rm --name tornode \
  --cap-add=NET_ADMIN --cap-add=NET_RAW \
  -e TAILSCALE_AUTH_KEY=tsnet... \
  tornode:latest
```

and use 

```
$ tailscale up --exit-node=tornode
$ curl -k https://check.torproject.org/api/ip
```

to make sure DNS is redirected

```
$ podman exec tornode /app/dns.sh
```

Note: this is experimental. Tor is not supposed to be used this way.

