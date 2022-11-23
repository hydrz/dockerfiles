FROM ubuntu:22.04

LABEL maintainer "hydrz <n.haoyuan@gmail.com>"

# Set Timezone
ARG TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG COREDNS_VERSION=1.10.0
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ADD https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_${TARGETOS}_${TARGETARCH}.tgz /tmp/coredns.tar.gz

RUN mkdir /app

RUN tar xf /tmp/coredns.tar.gz -C /app

RUN rm -rf /tmp/*

# add local files
COPY /root /

WORKDIR /app

EXPOSE 53/udp

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]