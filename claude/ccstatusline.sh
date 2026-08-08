#!/bin/sh
# Responsive launcher for ccstatusline.
#
# ccstatusline has no width-aware layout: it renders one fixed set of widgets and
# then hard-truncates the result to `flexMode`'s effective width. On a narrow
# terminal (phone over mosh) that means the status line gets clipped to
# "Model: Opus 5 | Ct..." instead of showing a layout that would actually fit.
#
# So: probe the terminal width and hand ccstatusline a config sized for it.
#
#   >= MEDIUM_BELOW cols -> ccstatusline.json         full layout, weekly progress bar
#   >= NARROW_BELOW cols -> ccstatusline.medium.json  labels kept, bar dropped
#   <  NARROW_BELOW cols -> ccstatusline.narrow.json  compact, fits ~24 cols
#
# Width is the right signal, not "am I on mosh?". Under a multiplexer the pane's
# pty is resized when a phone attaches, so the width already tracks the real
# viewport -- while the process tree does not: the multiplexer server is a
# daemon, so walking up from Claude Code lands on the machine's local tty and
# never reaches mosh-server at all.
#
# The probe mirrors ccstatusline's own (walk the parent chain for a tty, then
# stty), and the result is exported as CCSTATUSLINE_WIDTH so ccstatusline skips
# its own probe and agrees with the config we picked.
#
# Override for testing:  CCSTATUSLINE_WIDTH=40 ./ccstatusline.sh

MEDIUM_BELOW=100
NARROW_BELOW=60

# Resolve $0 through symlinks so the configs are found even if this script is
# linked into ~/bin or similar.
self=$0
while [ -L "$self" ]; do
    link=$(readlink "$self")
    case "$link" in
        /*) self=$link ;;
        *) self=$(dirname -- "$self")/$link ;;
    esac
done
DIR=$(CDPATH= cd -- "$(dirname -- "$self")" && pwd)

probe_width() {
    if [ -n "$CCSTATUSLINE_WIDTH" ]; then
        echo "$CCSTATUSLINE_WIDTH"
        return
    fi

    pid=$$
    depth=0
    while [ "$depth" -lt 8 ]; do
        depth=$((depth + 1))
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        [ -n "$pid" ] || break

        tty_name=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
        case "$tty_name" in
            '' | '?' | '??') continue ;;
        esac

        # The redirect form is POSIX and works on both macOS and Linux; -F (GNU)
        # and -f (BSD) are fallbacks for shells where the redirect is refused.
        dev=/dev/$tty_name
        cols=$(stty size <"$dev" 2>/dev/null | awk '{print $2}')
        case "$cols" in
            '' | *[!0-9]*) cols=$(stty -F "$dev" size 2>/dev/null | awk '{print $2}') ;;
        esac
        case "$cols" in
            '' | *[!0-9]*) cols=$(stty -f "$dev" size 2>/dev/null | awk '{print $2}') ;;
        esac
        case "$cols" in
            '' | *[!0-9]*) continue ;;
        esac
        [ "$cols" -gt 0 ] && { echo "$cols"; return; }
    done

    tput cols 2>/dev/null
}

width=$(probe_width)

config="$DIR/ccstatusline.json"
case "$width" in
    '' | *[!0-9]*) ;;  # unknown width: keep the full layout
    *)
        export CCSTATUSLINE_WIDTH="$width"
        if [ "$width" -lt "$NARROW_BELOW" ]; then
            config="$DIR/ccstatusline.narrow.json"
        elif [ "$width" -lt "$MEDIUM_BELOW" ]; then
            config="$DIR/ccstatusline.medium.json"
        fi
        ;;
esac

# bun is the fast path; fall back to npx so a machine without bun still works.
if command -v bunx >/dev/null 2>&1; then
    exec bunx -y ccstatusline@latest --config "$config"
elif command -v npx >/dev/null 2>&1; then
    exec npx -y ccstatusline@latest --config "$config"
elif command -v ccstatusline >/dev/null 2>&1; then
    exec ccstatusline --config "$config"
else
    echo "ccstatusline: need bunx, npx, or ccstatusline on PATH" >&2
    exit 1
fi
