FROM ubuntu:22.04

LABEL maintainer "hydrz <n.haoyuan@gmail.com>"

# Set Timezone
ARG TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Ca Certificates
RUN apt-get update -yqq && apt-get install -yqq ca-certificates && update-ca-certificates

# Add s6 overlay
ARG S6_OVERLAY_VERSION=3.1.2.1
ARG TARGETARCH
ENV OS_ARCH=${TARGETARCH:-amd64}
RUN apt-get update && apt-get install -yqq curl xz-utils
RUN \
    case ${OS_ARCH} in \
        "arm64") \
            OS_ARCH="aarch64";; \
        "arm") \
            OS_ARCH="armhf";; \
        "amd64") \
            OS_ARCH="x86_64";; \
        "386") \
            OS_ARCH="i686";; \
             echo "the arch $TARGETARCH not supported"; \
             exit 1; \
        esac; \
    curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${OS_ARCH}.tar.xz -o /tmp/s6-overlay.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

WORKDIR /

ENTRYPOINT ["/init"]