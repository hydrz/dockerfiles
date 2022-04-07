FROM hydrz:ubuntu:20.04

RUN apt-get update
RUN apt-get -y install ca-certificates && update-ca-certificates

ARG TARGETOS TARGETARCH

RUN \
 mkdir /app && \
 COREDNS_VERSION=$(curl -sX GET "https://api.github.com/repos/coredns/coredns/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]' | awk '{print substr($1,2); }') && \
 curl -o \
	/tmp/coredns.tar.gz -L \
	"https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_${TARGETOS}_${TARGETARCH}.tgz" && \
 tar xf \
	/tmp/coredns.tar.gz -C \
	/app

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

WORKDIR /app

EXPOSE 53 53/udp

ENTRYPOINT ["/app/coredns"]