FROM ubuntu:20.04

LABEL maintainer "hydrz <n.haoyuan@gmail.com>"

# Start as root
USER root

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

###########################################################################
# Always run apt update when start and after add new source list, then clean up at end.
###########################################################################

RUN set -xe; \
    apt-get update -yqq

###########################################################################
# Common Software's Installation
###########################################################################

RUN apt-get install -yqq \
    iputils-ping \
    iproute2 \
    iptables \
    net-tools \
    dnsutils \
    bridge-utils \
    tcpdump \
    ncat \
    htop \
    iotop \
    iftop \
    lsof \
    telnet\
    whois\
    traceroute\
    openssh-client \
    libzip-dev zip unzip \
    curl wget \
    git \
    vim

#--------------------------------------------------------------------------
# More Software's Installation
#--------------------------------------------------------------------------

# zsh
ARG OHMYZSH_REPO=https://gitee.com/mirrors/oh-my-zsh.git

RUN apt-get install -y zsh
RUN git clone $OHMYZSH_REPO ~/.oh-my-zsh
RUN cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
RUN chsh -s $(which zsh)
RUN sed -i "s@ZSH_THEME=\"robbyrussell\"@ZSH_THEME=\"ys\"@g" ~/.zshrc

#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# Set default work directory
WORKDIR /root