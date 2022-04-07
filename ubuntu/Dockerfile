FROM  ubuntu:20.04

LABEL maintainer "hydrz <n.haoyuan@gmail.com>"

###########################################################################
# CHANGE_SOURCE for in China
###########################################################################

ARG CHANGE_SOURCE=true
RUN if [ ${CHANGE_SOURCE} = true ]; then \
    sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list; \
    sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list; \
    fi;

###########################################################################
# Set Timezone
###########################################################################

ARG TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# set version for s6 overlay
ARG S6_OVERLAY_VERSION=3.1.0.1

# add s6 overlay
RUN apt-get update && apt-get install -y curl xz-utils

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp

ARG TARGETARCH
RUN \
    if [ "$TARGETARCH" = "amd64" ]; then \
        curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -o /tmp/s6-overlay.tar.xz; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz -o /tmp/s6-overlay.tar.xz; \
    elif [ "$TARGETARCH" = "ppc64le" ] || [ "$TARGETARCH" = "386" ]; then \
        echo "the arch $TARGETARCH not supported"; \
        exit 1; \
    else \
        curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${TARGETARCH}.tar.xz -o /tmp/s6-overlay.tar.xz; \
    fi;

RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay.tar.xz

#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

WORKDIR /

ENTRYPOINT ["/init"]