#!/bin/sh
# tailscale-bypass — let Tailscale keep working under a full-tunnel VPN.
#
# The OpenVPN server pushes `redirect-gateway def1`, installing 0/1 + 128.0/1
# routes that swallow ALL egress (including Tailscale's WireGuard/DERP UDP),
# which kills Tailscale (netcheck shows "UDP: false"). This pins ONLY Tailscale's
# infra — DERP relays + controlplane — to the physical gateway so that transport
# egresses en0/Wi-Fi. Everything else still goes out the VPN exit. More-specific
# host routes win over 0/1 + 128.0/1, so the full tunnel is otherwise untouched.
#
# Usage: tailscale-bypass.sh add|del     (PHYS_GW env overrides gateway detection)
set -eu

TS_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
[ -x "$TS_BIN" ] || TS_BIN="$(command -v tailscale 2>/dev/null || true)"
STATE="$HOME/.config/openvpn/tailscale-bypass.routes"

phys_gw() {
  # 0.0.0.0/0 default still points at the real router (VPN uses 0/1 + 128.0/1).
  route -n get default 2>/dev/null | awk '/gateway/{print $2; exit}'
}

ts_targets() {
  printf '192.200.0.0/24\n'                       # controlplane.tailscale.com range
  [ -n "${TS_BIN:-}" ] && [ -x "$TS_BIN" ] || return 0
  "$TS_BIN" debug derp-map 2>/dev/null \
    | jq -r '.Regions[].Nodes[].IPv4 | select(. != "")' 2>/dev/null | sort -u
}

case "${1:-}" in
  add)
    GW="${PHYS_GW:-$(phys_gw)}"
    [ -n "$GW" ] || { echo "tailscale-bypass: no physical gateway found" >&2; exit 1; }
    ts_targets > "$STATE.tmp"
    {
      while IFS= read -r ip; do
        [ -n "$ip" ] || continue
        case "$ip" in
          */*) echo "route -q -n add -net $ip $GW 2>/dev/null || route -q -n change -net $ip $GW 2>/dev/null || true";;
          *)   echo "route -q -n add -host $ip $GW 2>/dev/null || route -q -n change -host $ip $GW 2>/dev/null || true";;
        esac
      done < "$STATE.tmp"
    } | sudo sh
    mv "$STATE.tmp" "$STATE"
    echo "tailscale-bypass: pinned $(wc -l < "$STATE" | tr -d ' ') Tailscale routes via $GW"
    ;;
  del)
    [ -f "$STATE" ] || { echo "tailscale-bypass: nothing to remove"; exit 0; }
    {
      while IFS= read -r ip; do
        [ -n "$ip" ] || continue
        case "$ip" in
          */*) echo "route -q -n delete -net $ip 2>/dev/null || true";;
          *)   echo "route -q -n delete -host $ip 2>/dev/null || true";;
        esac
      done < "$STATE"
    } | sudo sh
    rm -f "$STATE"
    echo "tailscale-bypass: routes removed"
    ;;
  *) echo "usage: $0 {add|del}" >&2; exit 2;;
esac
