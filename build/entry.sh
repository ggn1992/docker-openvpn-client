#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cleanup() {
    kill TERM "$openvpn_pid"
    exit 0
}

is_enabled() {
    [[ ${1,,} =~ ^(true|t|yes|y|1|on|enable|enabled)$ ]]
}

# Check if CONFIG_FILE is set
if [[ -v CONFIG_FILE && -n $CONFIG_FILE ]]; then
    config_file=$(find /config -name "$CONFIG_FILE" 2> /dev/null | sort | shuf -n 1)
else
    config_file=$(find /config -name '*.conf' -o -name '*.ovpn' 2> /dev/null | sort | shuf -n 1)
fi

if [[ -z $config_file ]]; then
    echo "no openvpn configuration file found" >&2
    exit 1
fi

# Cleanup configs
if is_enabled "${CLEANUP_CONFIGS:-}"; then
    /usr/local/bin/cleanup-configs.sh
fi

echo "using openvpn configuration file: $config_file"

openvpn_args=(
    "--config" "$config_file"
    "--cd" "/config"
)

# Disable killswitch if no ALLOWED_SUBNETS is provided.
if is_enabled "${KILL_SWITCH:-}"; then
    if [[ -v ALLOWED_SUBNETS && -n $ALLOWED_SUBNETS ]]; then
        openvpn_args+=("--route-up" "/usr/local/bin/killswitch.sh $ALLOWED_SUBNETS")
    else
        echo "ALLOWED_SUBNETS is not set. Kill switch will not be enabled."
    fi
fi

# Docker secret that contains the credentials for accessing the VPN.
if [[ -v AUTH_SECRET && -n $AUTH_SECRET ]]; then
    openvpn_args+=("--auth-user-pass" "/run/secrets/$AUTH_SECRET")
fi

openvpn "${openvpn_args[@]}" &
openvpn_pid=$!

trap cleanup TERM

wait $openvpn_pid
