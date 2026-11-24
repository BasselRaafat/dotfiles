#!/usr/bin/env bash
set -euo pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
pid_file="$runtime_dir/hypridle-suspend-watch.pid"

on_ac_power() {
    local supply
    for supply in /sys/class/power_supply/*; do
        [[ -r "$supply/type" && -r "$supply/online" ]] || continue
        [[ "$(<"$supply/type")" == "Mains" ]] || continue
        [[ "$(<"$supply/online")" == "1" ]] && return 0
    done
    return 1
}

cancel_watch() {
    if [[ -r "$pid_file" ]]; then
        local pid
        pid="$(<"$pid_file")"
        if [[ "$pid" =~ ^[0-9]+$ ]]; then
            kill "$pid" 2>/dev/null || true
        fi
        rm -f "$pid_file"
    fi
}

case "${1:-start}" in
    start)
        cancel_watch
        (
            started_at="$(date +%s)"
            while true; do
                now="$(date +%s)"
                if ! on_ac_power || (( now - started_at >= 1200 )); then
                    rm -f "$pid_file"
                    systemctl suspend
                    exit 0
                fi
                sleep 5
            done
        ) >/dev/null 2>&1 &
        echo "$!" > "$pid_file"
        ;;
    cancel)
        cancel_watch
        ;;
    *)
        echo "Usage: $0 [start|cancel]" >&2
        exit 2
        ;;
esac
