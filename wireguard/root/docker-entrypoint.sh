#!/usr/bin/env bash

mkdir -p /config/{templates,coredns}

echo "Uname info: $(uname -a)"
# check for wireguard module
ip link del dev test 2>/dev/null
if ip link add dev test type wireguard; then
    echo "**** It seems the wireguard module is already active. Skipping kernel header install and module compilation. ****"
    ip link del dev test
else
    echo "**** make sure add --cap-add=NET_ADMIN flag to docker run command. ****"
    exit 1
fi

# prepare symlinks
rm -rf /etc/wireguard
mkdir -p /etc/wireguard
ln -s /config/wg0.conf /etc/wireguard/wg0.conf

# prepare templates
[[ ! -f /config/templates/server.conf ]] &&
    cp /defaults/server.conf /config/templates/server.conf
[[ ! -f /config/templates/peer.conf ]] &&
    cp /defaults/peer.conf /config/templates/peer.conf

# add preshared key to user templates (backwards compatibility)
if ! grep -q 'PresharedKey' /config/templates/peer.conf; then
    sed -i 's|^Endpoint|PresharedKey = \$\(cat /config/\${PEER_ID}/presharedkey-\${PEER_ID}\)\nEndpoint|' /config/templates/peer.conf
fi

generate_confs() {
    mkdir -p /config/server
    if [ ! -f /config/server/privatekey-server ]; then
        umask 077
        wg genkey | tee /config/server/privatekey-server | wg pubkey >/config/server/publickey-server
    fi
    eval "$(printf %s)
  cat <<DUDE > /config/wg0.conf
$(cat /config/templates/server.conf)

DUDE"
    for i in ${PEERS_ARRAY[@]}; do
        if [[ ! "${i}" =~ ^[[:alnum:]]+$ ]]; then
            echo "**** Peer ${i} contains non-alphanumeric characters and thus will be skipped. No config for peer ${i} will be generated. ****"
        else
            if [[ "${i}" =~ ^[0-9]+$ ]]; then
                PEER_ID="peer${i}"
            else
                PEER_ID="peer_${i}"
            fi
            mkdir -p /config/${PEER_ID}
            if [ ! -f "/config/${PEER_ID}/privatekey-${PEER_ID}" ]; then
                umask 077
                wg genkey | tee /config/${PEER_ID}/privatekey-${PEER_ID} | wg pubkey >/config/${PEER_ID}/publickey-${PEER_ID}
                wg genpsk >/config/${PEER_ID}/presharedkey-${PEER_ID}
            fi
            if [ -f "/config/${PEER_ID}/${PEER_ID}.conf" ]; then
                CLIENT_IP=$(cat /config/${PEER_ID}/${PEER_ID}.conf | grep "Address" | awk '{print $NF}')
                if [ -n "${ORIG_INTERFACE}" ] && [ "${INTERFACE}" != "${ORIG_INTERFACE}" ]; then
                    CLIENT_IP=$(echo "${CLIENT_IP}" | sed "s|${ORIG_INTERFACE}|${INTERFACE}|")
                fi
            else
                for idx in {2..254}; do
                    PROPOSED_IP="${INTERFACE}.${idx}"
                    if ! grep -q -R "${PROPOSED_IP}" /config/peer*/*.conf 2>/dev/null && ([ -z "${ORIG_INTERFACE}" ] || ! grep -q -R "${ORIG_INTERFACE}.${idx}" /config/peer*/*.conf 2>/dev/null); then
                        CLIENT_IP="${PROPOSED_IP}"
                        break
                    fi
                done
            fi
            if [ -f "/config/${PEER_ID}/presharedkey-${PEER_ID}" ]; then
                # create peer conf with presharedkey
                eval "$(printf %s)
        cat <<DUDE > /config/${PEER_ID}/${PEER_ID}.conf
$(cat /config/templates/peer.conf)
DUDE"
                # add peer info to server conf with presharedkey
                cat <<DUDE >>/config/wg0.conf
[Peer]
# ${PEER_ID}
PublicKey = $(cat /config/${PEER_ID}/publickey-${PEER_ID})
PresharedKey = $(cat /config/${PEER_ID}/presharedkey-${PEER_ID})
DUDE
            else
                echo "**** Existing keys with no preshared key found for ${PEER_ID}, creating confs without preshared key for backwards compatibility ****"
                # create peer conf without presharedkey
                eval "$(printf %s)
        cat <<DUDE > /config/${PEER_ID}/${PEER_ID}.conf
$(cat /config/templates/peer.conf | sed '/PresharedKey/d')
DUDE"
                # add peer info to server conf without presharedkey
                cat <<DUDE >>/config/wg0.conf
[Peer]
# ${PEER_ID}
PublicKey = $(cat /config/${PEER_ID}/publickey-${PEER_ID})
DUDE
            fi
            SERVER_ALLOWEDIPS=SERVER_ALLOWEDIPS_PEER_${i}
            # add peer's allowedips to server conf
            if [ -n "${!SERVER_ALLOWEDIPS}" ]; then
                echo "Adding ${!SERVER_ALLOWEDIPS} to wg0.conf's AllowedIPs for peer ${i}"
                cat <<DUDE >>/config/wg0.conf
AllowedIPs = ${CLIENT_IP}/32,${!SERVER_ALLOWEDIPS}

DUDE
            else
                cat <<DUDE >>/config/wg0.conf
AllowedIPs = ${CLIENT_IP}/32

DUDE
            fi
            if [ -z "${LOG_CONFS}" ] || [ "${LOG_CONFS}" = "true" ]; then
                echo "PEER ${i} QR code:"
                qrencode -t ansiutf8 </config/${PEER_ID}/${PEER_ID}.conf
            else
                echo "PEER ${i} conf and QR code png saved in /config/${PEER_ID}"
            fi
            qrencode -o /config/${PEER_ID}/${PEER_ID}.png </config/${PEER_ID}/${PEER_ID}.conf
        fi
    done
}

save_vars() {
    cat <<DUDE >/config/.donoteditthisfile
ORIG_SERVERURL="$SERVERURL"
ORIG_SERVERPORT="$SERVERPORT"
ORIG_PEERDNS="$PEERDNS"
ORIG_PEERS="$PEERS"
ORIG_INTERFACE="$INTERFACE"
ORIG_ALLOWEDIPS="$ALLOWEDIPS"
DUDE
}

if [ -n "$PEERS" ]; then
    echo "**** Server mode is selected ****"
    if [[ "$PEERS" =~ ^[0-9]+$ ]] && ! [[ "$PEERS" =~ *,* ]]; then
        PEERS_ARRAY=($(seq 1 $PEERS))
    else
        PEERS_ARRAY=($(echo "$PEERS" | tr ',' ' '))
    fi
    PEERS_COUNT=$(echo "${#PEERS_ARRAY[@]}")
    if [ -z "$SERVERURL" ] || [ "$SERVERURL" = "auto" ]; then
        SERVERURL=$(curl -s icanhazip.com)
        echo "**** SERVERURL var is either not set or is set to \"auto\", setting external IP to auto detected value of $SERVERURL ****"
    else
        echo "**** External server address is set to $SERVERURL ****"
    fi
    SERVERPORT=${SERVERPORT:-51820}
    echo "**** External server port is set to ${SERVERPORT}. Make sure that port is properly forwarded to port 51820 inside this container ****"
    INTERNAL_SUBNET=${INTERNAL_SUBNET:-10.13.13.0}
    echo "**** Internal subnet is set to $INTERNAL_SUBNET ****"
    INTERFACE=$(echo "$INTERNAL_SUBNET" | awk 'BEGIN{FS=OFS="."} NF--')
    ALLOWEDIPS=${ALLOWEDIPS:-0.0.0.0/0, ::/0}
    echo "**** AllowedIPs for peers $ALLOWEDIPS ****"
    if [ -z "$PEERDNS" ] || [ "$PEERDNS" = "auto" ]; then
        PEERDNS="${INTERFACE}.1"
        echo "**** PEERDNS var is either not set or is set to \"auto\", setting peer DNS to ${INTERFACE}.1 to use wireguard docker host's DNS. ****"
    else
        echo "**** Peer DNS servers will be set to $PEERDNS ****"
    fi
    if [ ! -f /config/wg0.conf ]; then
        echo "**** No wg0.conf found (maybe an initial install), generating 1 server and ${PEERS} peer/client confs ****"
        generate_confs
        save_vars
    else
        echo "**** Server mode is selected ****"
        [[ -f /config/.donoteditthisfile ]] &&
            . /config/.donoteditthisfile
        if [ "$SERVERURL" != "$ORIG_SERVERURL" ] || [ "$SERVERPORT" != "$ORIG_SERVERPORT" ] || [ "$PEERDNS" != "$ORIG_PEERDNS" ] || [ "$PEERS" != "$ORIG_PEERS" ] || [ "$INTERFACE" != "$ORIG_INTERFACE" ] || [ "$ALLOWEDIPS" != "$ORIG_ALLOWEDIPS" ]; then
            echo "**** Server related environment variables changed, regenerating 1 server and ${PEERS} peer/client confs ****"
            generate_confs
            save_vars
        else
            echo "**** No changes to parameters. Existing configs are used. ****"
        fi
    fi
else
    echo "**** Client mode selected. ****"
    if [ ! -f /config/wg0.conf ]; then
        echo "**** No client conf found. Provide your own client conf as \"/config/wg0.conf\". ****"
        exit 1
    fi
    if [ -z "$USE_COREDNS" ]; then
        USE_COREDNS="false"
    fi
fi

# set up CoreDNS
[[ ! -f /config/coredns/Corefile ]] &&
    cp /defaults/Corefile /config/coredns/Corefile

# svc wireguard
wg-quick up wg0
trap 'echo "**** Down wg0 interface ****"; wg-quick down wg0' TERM INT

# check port 53
if netstat -apn | grep -q ":53 "; then
    USE_COREDNS="false"
fi

if [[ ${USE_COREDNS} == "false" ]]; then
    echo "**** Disabling CoreDNS ****"
    sleep infinity &
    PID=$1
else
    /app/coredns -dns.port=53 -conf /config/coredns/Corefile &
    PID=$1
fi

wait $PID
