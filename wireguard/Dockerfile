FROM ubuntu:22.04

LABEL maintainer "hydrz <n.haoyuan@gmail.com>"

# Set Timezone
ARG TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Always run apt update when start, then clean up at end.
RUN apt-get update

# Install dependencies 
RUN apt-get install -y --no-install-recommends \ 
	curl \
	ca-certificates \
	ifupdown \
	iproute2 \
	iptables \
	iputils-ping \
	net-tools \
	netcat ; \
	update-ca-certificates ; \
	update-alternatives --set iptables /usr/sbin/iptables-legacy

# Prepare working dir
RUN mkdir -p /app && cd /app
WORKDIR /app

# Install wireguard
RUN apt-get install -y --no-install-recommends \
	wireguard \
	qrencode

# Install CoreDNS
ARG COREDNS_VERSION=1.10.0
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ADD https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_${TARGETOS}_${TARGETARCH}.tgz /tmp/coredns.tar.gz
RUN tar xf /tmp/coredns.tar.gz -C /app

# Clean up
RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	rm /var/log/lastlog /var/log/faillog

# add local files
COPY /root /

# ports and volumes
EXPOSE 51820/udp
EXPOSE 53/udp

ENTRYPOINT ["/docker-entrypoint.sh"]