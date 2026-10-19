# modules/ui/lock/_lib/lock-events.sh
# Tells the shell when logind wants the screen locked. Run by the shell,
# which reads one word per line on stdout:
#
#   lock    `loginctl lock-session` (logind's Lock signal for this session)
#   sleep   the machine is about to suspend
#
# After `sleep` it waits for one line on stdin, sent once the lock is secure,
# and exits; the shell starts it again. Suspend waits for that exit: the
# whole watch runs under a logind delay inhibitor, which is released only
# when this process ends. logind waits at most InhibitDelayMaxSec (5 s by
# default), so the wait for the shell gives up after 4. Ported from omarchy's
# omarchy-system-sleep-monitor. busctl and systemd-inhibit are the system's,
# from PATH, so they match the logind running.

budget=4

watch() {
    local path=$1 line asked=0
    # The shell's pipe, kept apart from dbus-monitor's output.
    exec 3<&0

    exec 4< <(dbus-monitor --system \
        "type='signal',sender='org.freedesktop.login1',path='$path',interface='org.freedesktop.login1.Session',member='Lock'" \
        "type='signal',sender='org.freedesktop.login1',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'")
    local monitor=$!
    trap 'kill "$monitor" 2>/dev/null' EXIT

    while IFS= read -r line <&4; do
        case $line in
        *member=Lock*) echo lock ;;
        *member=PrepareForSleep*) asked=1 ;;
        *"boolean true"*)
            if ((asked)); then
                echo sleep
                read -r -t "$budget" _ <&3 || echo "sarisarinama-lock-events: suspending before the lock was secure" >&2
                exit 0
            fi
            ;;
        *"boolean false"*) asked=0 ;;
        esac
    done
}

if [ "${1:-}" = --watch ]; then
    watch "$2"
    exit 0
fi

# The session this shell runs in: pam_systemd exports XDG_SESSION_ID to it.
path=$(busctl --system call org.freedesktop.login1 /org/freedesktop/login1 \
    org.freedesktop.login1.Manager GetSession s "${XDG_SESSION_ID:-auto}")
path=${path#o \"}
path=${path%\"}

exec systemd-inhibit --what=sleep --mode=delay --who=sarisarinama \
    --why="Lock the screen before suspend" "$0" --watch "$path"
