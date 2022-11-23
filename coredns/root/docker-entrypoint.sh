#!/usr/bin/env bash

# set up CoreDNS
mkdir -p /app/config/coredns

[[ ! -f /app/config/coredns/Corefile ]] &&
    cp /defaults/Corefile /app/config/coredns/Corefile

trap 'echo "Shutdowning...";' TERM INT

/app/coredns -dns.port=53 -conf /app/config/coredns/Corefile &
PID=$1
wait $PID
