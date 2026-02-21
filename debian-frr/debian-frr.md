# Debian FRR MVP

## 1) Proxmox host

Create template VM:
```bash
./proxmox-host.sh create
```
Expected:
- `qm` create/set/start output
- VM `900` starts

Finalize template:
```bash
./proxmox-host.sh finalize
```
Expected:
- waits until VM `900` is stopped
- `qm template` output

Create and start two clones:
```bash
./proxmox-host.sh clone
```
Expected:
- `qm clone` / `qm start` output
- clones `1101` (`r1`) and `1102` (`r2`) running

## 2) Template guest bake (inside template VM as root)

```bash
./template-bake.sh
```
Expected:
- package install output
- `systemctl`/`sysctl` output
- VM powers off at the end

## 3) Clone verify (inside clone as root)

```bash
./clone-verify.sh
```
Expected on success:
- first line: machine-id (32 hex chars)
- last line: `OK`
- exit code `0`
