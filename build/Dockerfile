FROM alpine:3.20

RUN apk add --no-cache \
    bash \
    bind-tools \
    iptables \
    ip6tables \
    openvpn

COPY . /usr/local/bin

ENV KILL_SWITCH=on
ENV CLEANUP_CONFIGS=on

ENTRYPOINT [ "entry.sh" ]
