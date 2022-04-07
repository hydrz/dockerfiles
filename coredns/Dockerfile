FROM hydrz/ubuntu:20.04

LABEL maintainer "hydrz <n.haoyuan@gmail.com>"

RUN set -xe; \
    echo "**** install CoreDNS ****" && \
    COREDNS_VERSION=$(curl -sX GET "https://api.github.com/repos/coredns/coredns/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]' | awk '{print substr($1,2); }') && \
    curl -o \
    /tmp/coredns.tar.gz -L \
    "https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_arm64.tgz" && \
    tar xf \
    /tmp/coredns.tar.gz -C \
    /app && \
    echo "**** clean up ****" && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 53/tcp 53/udp 