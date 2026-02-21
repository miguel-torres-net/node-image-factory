#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  frr frr-pythontools qemu-guest-agent

systemctl enable --now qemu-guest-agent || true

# Multiprotocol Label Switching (MPLS) modules
cat >/etc/modules-load.d/mpls.conf <<'EOT'
mpls_router
mpls_iptunnel
EOT
modprobe -a mpls_router mpls_iptunnel

# sysctls
cat >/etc/sysctl.d/99-router.conf <<'EOT'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.mpls.platform_labels=100000
EOT
sysctl -p /etc/sysctl.d/99-router.conf

# enable MPLS on all interfaces (except lo/all/default)
cat >/usr/local/sbin/mpls-apply.sh <<'EOT'
#!/usr/bin/env bash
set -euo pipefail
modprobe -a mpls_router mpls_iptunnel
BASE="/proc/sys/net/mpls/conf"
[[ -d "$BASE" ]] || exit 0
shopt -s nullglob
for f in "$BASE"/*/input; do
  iface="$(basename "$(dirname "$f")")"
  case "$iface" in lo|all|default) continue ;; esac
  echo 1 > "$f"
done
EOT
chmod 0755 /usr/local/sbin/mpls-apply.sh

cat >/etc/systemd/system/mpls-apply.service <<'EOT'
[Unit]
Description=Apply MPLS ingress settings
After=network.target
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/mpls-apply.sh
[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable --now mpls-apply.service

# FRRouting (FRR) daemons (brute-force simple)
sed -i -E 's/^zebra=.*/zebra=yes/' /etc/frr/daemons
sed -i -E 's/^isisd=.*/isisd=yes/' /etc/frr/daemons
sed -i -E 's/^bgpd=.*/bgpd=yes/' /etc/frr/daemons
sed -i -E 's/^ldpd=.*/ldpd=yes/' /etc/frr/daemons

systemctl enable --now frr

# template hygiene
rm -f /etc/ssh/ssh_host_*
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sfn /etc/machine-id /var/lib/dbus/machine-id
command -v cloud-init >/dev/null 2>&1 && cloud-init clean --logs || true

sync
poweroff
