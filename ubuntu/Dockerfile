FROM  ubuntu:20.04

LABEL maintainer "hydrz <n.haoyuan@gmail.com>"

# set version for s6 overlay
ARG S6_OVERLAY_VERSION=3.1.0.1

# add s6 overlay
RUN apt-get update && apt-get install -y curl xz-utils

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp

ARG TARGETARCH
RUN \
    if [ "$TARGETARCH" = "amd64" ]; then \
        export OVERLAY_ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        export OVERLAY_ARCH="aarch64"; \
    elif [ "$TARGETARCH" = "ppc64le" ] || [ "$TARGETARCH" = "386" ]; then \
        echo "the arch $TARGETARCH not supported"; \
        exit 1; \
    else \
        export OVERLAY_ARCH=${$TARGETARCH} ; \
    fi; \
    curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.xz -o /tmp/s6-overlay.tar.xz

RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay.tar.xz

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

ENTRYPOINT ["/init"]