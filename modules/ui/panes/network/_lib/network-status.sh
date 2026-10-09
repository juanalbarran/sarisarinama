# modules/ui/panes/network/_lib/network-status.sh
# One sample of the active connection, for the network panel's stats:
# `key<TAB>value` lines for iface, ip, prefix, gateway, rx_bytes, tx_bytes
# and ping_ms. Prints nothing when there is no default route. ping_ms is
# printed empty when the ping gets no answer, which the panel counts as a
# lost packet.
#
# ping is the system's, from PATH: sending ICMP needs a privilege that only
# the system's copy has (a capability on most distributions, a wrapper in
# /run/wrappers/bin on NixOS). A ping from the Nix store would be refused.

host="${SARISARINAMA_PING_HOST:-1.1.1.1}"

route=$(ip -4 route show default | head -n 1)
[ -n "$route" ] || exit 0

# "default via 10.0.0.1 dev wlan0 proto dhcp ...": the word after each key.
gateway=""
iface=""
read -ra words <<<"$route"
for ((i = 0; i < ${#words[@]} - 1; i++)); do
    case "${words[i]}" in
    via) gateway="${words[i + 1]}" ;;
    dev) iface="${words[i + 1]}" ;;
    esac
done
[ -n "$iface" ] || exit 0

# "3: wlan0    inet 10.0.0.23/24 brd ...": the word after "inet".
address=""
read -ra words <<<"$(ip -4 -o addr show dev "$iface" | head -n 1)"
for ((i = 0; i < ${#words[@]} - 1; i++)); do
    if [ "${words[i]}" = inet ]; then
        address="${words[i + 1]}"
        break
    fi
done

stats="/sys/class/net/$iface/statistics"

# One echo request, one second to answer; prints the round trip in ms.
ping_ms() {
    local out
    out=$(ping -n -c 1 -W 1 "$1" 2>/dev/null) || return 0
    if [[ $out =~ time=([0-9.]+) ]]; then
        printf '%s' "${BASH_REMATCH[1]}"
    fi
}

printf 'iface\t%s\n' "$iface"
printf 'ip\t%s\n' "${address%/*}"
printf 'prefix\t%s\n' "${address#*/}"
printf 'gateway\t%s\n' "$gateway"
printf 'rx_bytes\t%s\n' "$(cat "$stats/rx_bytes")"
printf 'tx_bytes\t%s\n' "$(cat "$stats/tx_bytes")"
printf 'ping_ms\t%s\n' "$(ping_ms "$host")"
