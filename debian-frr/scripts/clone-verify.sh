#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

cat /etc/machine-id
lsmod | grep -E '^mpls_(router|iptunnel)\b' >/dev/null
sysctl -n net.mpls.platform_labels >/dev/null

for f in /proc/sys/net/mpls/conf/*/input; do
  iface="$(basename "$(dirname "$f")")"
  case "$iface" in lo|all|default) continue ;; esac
  [[ "$(cat "$f")" == "1" ]]
done

systemctl is-active --quiet mpls-apply.service
systemctl is-active --quiet frr

echo "OK"
