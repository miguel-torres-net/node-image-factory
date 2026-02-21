#!/usr/bin/env bash
set -euo pipefail

VMID=900
NAME="template-debian-frr"
IMG="/var/lib/vz/template/iso/debian-12-generic-amd64.qcow2"
SSHKEY="/root/.ssh/id_ed25519pub"
STORAGE="local-lvm"
BRIDGE="vmbr0"

MODE="${1:-}"

case "$MODE" in
  create)
    qm destroy "$VMID" --purge 1 >/dev/null 2>&1 || true

    qm create "$VMID" --name "$NAME" --ostype l26 --memory 2048 --cores 2 \
      --net0 "virtio,bridge=$BRIDGE" \
      --scsihw virtio-scsi-pci \
      --scsi0 "$STORAGE:0,import-from=$IMG" \
      --ide2 "$STORAGE:cloudinit" \
      --boot order=scsi0 \
      --serial0 socket --vga serial0 \
      --agent enabled=1

    qm resize "$VMID" scsi0 16G
    qm set "$VMID" --ciuser debian --ipconfig0 ip=dhcp --sshkeys "$SSHKEY"
    qm start "$VMID"
    ;;

  finalize)
    # assume guest powered off; just wait
    while [[ "$(qm status "$VMID" | awk '{print $2}')" != "stopped" ]]; do
      sleep 2
    done
    qm template "$VMID"
    ;;

  clone)
    # two demo clones
    qm destroy 1101 --purge 1 >/dev/null 2>&1 || true
    qm destroy 1102 --purge 1 >/dev/null 2>&1 || true
    qm clone "$VMID" 1101 --name r1 --full 1
    qm clone "$VMID" 1102 --name r2 --full 1
    qm start 1101
    qm start 1102
    ;;

  *)
    echo "Usage: $0 {create|finalize|clone}"
    exit 1
    ;;
esac
