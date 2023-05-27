#!/bin/sh

iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-port 5353
