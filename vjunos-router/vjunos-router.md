# vjunos-router

## Files
- `build-node.sh`
- `pe1.json` (example input)

## Required on Proxmox host
- `qemu-img`
- `jq`
- local vJunos base QCOW2 path (set in JSON)
- Juniper `make-config.sh` path (set in JSON)

## 1) Build node artifacts

```bash
cd vjunos-router
./build-node.sh ./pe1.json
```

Output:
- `vjunos/pe1/disk.qcow2`
- `vjunos/pe1/config.img`
- `vjunos/pe1/rendered/juniper.conf`

## 2) Create VM in Proxmox

```bash
VMID=2101
NAME=pe1
STORAGE=local-lvm
BRIDGE=vmbr0
ROOT_DIR="$(pwd)"

qm destroy "$VMID" --purge 1 >/dev/null 2>&1 || true

qm create "$VMID" \
  --name "$NAME" \
  --ostype l26 \
  --memory 4096 \
  --cores 2 \
  --scsihw virtio-scsi-pci \
  --scsi0 "$STORAGE:0,import-from=$ROOT_DIR/vjunos/$NAME/disk.qcow2" \
  --scsi1 "$STORAGE:0,import-from=$ROOT_DIR/vjunos/$NAME/config.img" \
  --boot order=scsi0 \
  --serial0 socket \
  --vga serial0 \
  --net0 "virtio,bridge=$BRIDGE"

qm start "$VMID"
```

## 3) What Day-0 injects
- hostname
- `fxp0` management IP (`mgmt_ip_cidr` in JSON)
- `chassis { no-auto-image-upgrade; }`
