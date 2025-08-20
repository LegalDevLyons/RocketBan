#!/bin/bash
# RocketBan - Fail2Ban wrapper script
# Author: Your Name
# License: MIT

CONFIG_FILE=""
DRY_RUN=false
VERBOSE=false
UNBAN=false

declare -A BAN_LIST
declare -A LAST_SEEN

load_config() {
    local section=""
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//g' | xargs)
        [[ -z "$line" ]] && continue
        if [[ "$line" =~

\[(.*)\]

 ]]; then
            section="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            eval "${section}_${key}=\"$value\""
        fi
    done < "$CONFIG_FILE"
}

parse_logs() {
    local service="$1"
    local log_path=$(eval echo "\${${service}_log_path}")
    local pattern=$(eval echo "\${${service}_pattern}")
    local threshold=$(eval echo "\${${service}_threshold}")
    local ban_time=$(eval echo "\${${service}_ban_time}")

    grep -E "$pattern" "$log_path" | while read -r line; do
        if [[ "$line" =~ $pattern ]]; then
            ip="${BASH_REMATCH[1]}"
            ((BAN_LIST["$ip"]++))
            LAST_SEEN["$ip"]=$(date +%s)
            if [[ ${BAN_LIST["$ip"]} -ge $threshold ]]; then
                ban_ip "$ip" "$service"
            fi
        fi
    done
}

ban_ip() {
    local ip="$1"
    local service="$2"
    local firewall=$(eval echo "\${${service}_firewall}")
    local ban_time=$(eval echo "\${${service}_ban_time}")

    if $DRY_RUN; then
        echo "[DRY RUN] Would ban $ip via $firewall"
        return
    fi

    if $VERBOSE; then
        echo "[BAN] $ip via $firewall for $ban_time seconds"
    fi

    if [[ "$firewall" == "iptables" ]]; then
        iptables -I INPUT -s "$ip" -j DROP
    elif [[ "$firewall" == "nftables" ]]; then
        nft add rule inet filter input ip saddr "$ip" drop
    fi

    echo "$ip,$(date +%s),$ban_time" >> banned_ips.log
}

unban_ips() {
    if [[ ! -f banned_ips.log ]]; then return; fi

    local now=$(date +%s)
    local temp_file=$(mktemp)

    while IFS= read -r line; do
        IFS=',' read -r ip timestamp duration <<< "$line"
        if (( now - timestamp >= duration )); then
            if $VERBOSE; then
                echo "[UNBAN] $ip"
            fi
            iptables -D INPUT -s "$ip" -j DROP 2>/dev/null
            nft delete rule inet filter input ip saddr "$ip" drop 2>/dev/null
        else
            echo "$line" >> "$temp_file"
        fi
    done < banned_ips.log

    mv "$temp_file" banned_ips.log
}

main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config) CONFIG_FILE="$2"; shift ;;
            -d|--dry-run) DRY_RUN=true ;;
            -v|--verbose) VERBOSE=true ;;
            --unban) UNBAN=true ;;
            *) echo "Unknown option: $1"; exit 1 ;;
        esac
        shift
    done

    if [[ -z "$CONFIG_FILE" ]]; then
        echo "Usage: $0 -c config.conf [-d] [-v] [--unban]"
        exit 1
    fi

    load_config

    if $UNBAN; then
        unban_ips
        exit 0
    fi

    for section in $(grep -oP '^

\[\K[^\]

]+' "$CONFIG_FILE"); do
        parse_logs "$section"
    done
}

main "$@"
