VMID=1101
NAME="pe1-junos"
STORAGE="local-lvm"
MGMT_BRIDGE="vmbr0"

DISK_PATH="/root/node-image-factory/vjunos-router/vjunos/pe1-junos/disk.qcow2"
CFG_PATH="/root/node-image-factory/vjunos-router/vjunos/pe1-junos/config.img"

[[ -f "$DISK_PATH" ]] || { echo "Missing DISK_PATH: $DISK_PATH"; exit 2; }
[[ -f "$CFG_PATH"  ]] || { echo "Missing CFG_PATH:  $CFG_PATH";  exit 2; }

qm stop "$VMID" >/dev/null 2>&1 || true
qm destroy "$VMID" >/dev/null 2>&1 || true

qm create "$VMID" --name "$NAME" --memory 5120 --cores 4 \
  --cpu host \
  --boot order=virtio0 --serial0 socket --vga serial0 \
  --net0 "virtio,bridge=$MGMT_BRIDGE"

# Import + attach main disk
qm disk import "$VMID" "$DISK_PATH" "$STORAGE" --format qcow2 >/dev/null
MAIN_VOL="$(qm config "$VMID" | awk '/^unused0:/ {print $2; exit}')"
qm set "$VMID" --virtio0 "$MAIN_VOL",iothread=1

# vJunos-router expects config drive as USB
qm set "$VMID" --args "-smbios type=1,product=VM-VMX -device qemu-xhci,id=xhci -drive if=none,format=raw,file=${CFG_PATH},id=cfg0 -device usb-storage,drive=cfg0"
qm start "$VMID"
