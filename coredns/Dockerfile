FROM hydrz/ubuntu:22.04

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

# add local files
COPY /root /

WORKDIR /app

EXPOSE 53 53/udp