# [dockerfiles](https://github.com/hydrz/dockerfiles)

Some Dockerfiles I use as a supplement.

## ubuntu 
[![ubuntu](https://github.com/hydrz/dockerfiles/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/hydrz/dockerfiles/actions/workflows/ubuntu.yml)

ubuntu with [s6-overlay](https://github.com/just-containers/s6-overlay)

## workspace 
[![workspace](https://github.com/hydrz/dockerfiles/actions/workflows/workspace.yml/badge.svg)](https://github.com/hydrz/dockerfiles/actions/workflows/workspace.yml)

ubuntu with common softwares for do some test.

## coredns 
[![coredns](https://github.com/hydrz/dockerfiles/actions/workflows/coredns.yml/badge.svg)](https://github.com/hydrz/dockerfiles/actions/workflows/coredns.yml)

coredns

## wireguard
[![wireguard](https://github.com/hydrz/dockerfiles/actions/workflows/wireguard.yml/badge.svg)](https://github.com/hydrz/dockerfiles/actions/workflows/wireguard.yml)

modify from [https://github.com/linuxserver/docker-wireguard](https://github.com/linuxserver/docker-wireguard)

> Since the `chown /config` in the original version will cause errors when using configmap in kubernetes, it can be modified to avoid using `initContainer` to start.

[Readme](wireguard/README.md)