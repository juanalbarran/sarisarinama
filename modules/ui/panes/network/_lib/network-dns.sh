# modules/ui/panes/network/_lib/network-dns.sh
# The DNS servers of the connected network, for the panel's DNS row. Only
# that network's saved profile changes: no root is needed, and every other
# network keeps its own DNS.
#
#   sarisarinama-network-dns               prints profile, auto, servers
#   sarisarinama-network-dns dhcp          the servers the network hands out
#   sarisarinama-network-dns set SERVER... these servers instead, IPv4 or IPv6
#
# nmcli is the system's, from PATH, so it always matches the NetworkManager
# running.

# Every read goes through here: LC_ALL=C because nmcli translates its words;
# -e no because -g would otherwise escape ':' in IPv6 addresses.
nm_get() {
    LC_ALL=C nmcli -e no -g "$@" 2>/dev/null
}

# The device carrying the default route: "default via ... dev wlan0 ...".
device=""
route=""
read -r route < <(ip -4 route show default) || true
read -ra words <<<"$route"
for ((i = 0; i < ${#words[@]} - 1; i++)); do
    if [ "${words[i]}" = dev ]; then
        device="${words[i + 1]}"
    fi
done

uuid=""
if [ -n "$device" ]; then
    uuid=$(nm_get GENERAL.CON-UUID device show "$device")
fi

if [ $# -eq 0 ]; then
    [ -n "$uuid" ] || exit 0
    # One value per line, in the order asked for.
    {
        read -r profile
        read -r ignore
        read -r v4
        read -r v6
    } < <(nm_get connection.id,ipv4.ignore-auto-dns,ipv4.dns,ipv6.dns connection show uuid "$uuid")
    auto=yes
    [ "$ignore" != yes ] || auto=no
    servers="${v4//,/ } ${v6//,/ }"
    read -ra servers <<<"$servers"
    printf 'profile\t%s\n' "$profile"
    printf 'auto\t%s\n' "$auto"
    printf 'servers\t%s\n' "${servers[*]}"
    exit 0
fi

if [ -z "$uuid" ]; then
    echo "No connection" >&2
    exit 1
fi

case "$1" in
dhcp)
    nmcli connection modify uuid "$uuid" \
        ipv4.ignore-auto-dns no ipv4.dns "" \
        ipv6.ignore-auto-dns no ipv6.dns "" >/dev/null
    ;;
set)
    shift
    v4=""
    v6=""
    for server in "$@"; do
        # An address only: digits, hex and the separators. Anything else is
        # refused before it reaches nmcli.
        if [[ ! $server =~ ^[0-9A-Fa-f.:]+$ ]]; then
            echo "Not an IP address: $server" >&2
            exit 2
        fi
        if [[ $server == *:* ]]; then
            v6="${v6:+$v6,}$server"
        else
            v4="${v4:+$v4,}$server"
        fi
    done
    if [ -z "$v4$v6" ]; then
        echo "No servers given" >&2
        exit 2
    fi
    # The network's own servers are ignored for both IP versions, or an
    # IPv6 router could still hand out its DNS beside the chosen one.
    nmcli connection modify uuid "$uuid" \
        ipv4.ignore-auto-dns yes ipv4.dns "$v4" \
        ipv6.ignore-auto-dns yes ipv6.dns "$v6" >/dev/null
    ;;
*)
    echo "Usage: sarisarinama-network-dns [dhcp | set SERVER...]" >&2
    exit 2
    ;;
esac

# Reapply puts the new DNS in place without dropping the connection; when the
# device refuses it, reconnecting does the same.
nmcli device reapply "$device" >/dev/null 2>&1 ||
    nmcli -w 30 connection up uuid "$uuid" >/dev/null
