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
RUN \ 
	COREDNS_VERSION=$(curl -sX GET "https://api.github.com/repos/coredns/coredns/releases/latest" \
		| awk '/tag_name/{print $4;exit}' FS='[""]' | awk '{print substr($1,2); }') ; \
	curl -o \
		/tmp/coredns.tar.gz -L \
		"https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_amd64.tgz" ; \
	tar xf \
		/tmp/coredns.tar.gz -C \
		/app ;

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