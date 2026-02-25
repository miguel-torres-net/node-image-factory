# node-image-factory

NOTE: CURRENTLY WORKING ON IT.
As of 25 Feb: Proved isis adjacency works with the manual tweaks I did, so now I'll focus on refactoring the scripts I use to parameterize (I had to google how to spell that word) things like VM ID, VM name, ssh pubkey, etc

This is my working repo for the Utilities Carrier lab.

I use it to generate VM artifacts and bootstrap configs so I can spin nodes up quickly in Proxmox without repeating manual steps.

Current focus:
- `debian-frr/` for lightweight core/lab router templates
- `vjunos-router/` for PE-style nodes with minimal Day-0 injection
- `vyos-cpe/` and `iec-104-node/` are placeholders I will fill in as the lab evolves

The goal is simple: keep node bring-up reproducible and practical while I build the full lab.

My goal is to be able to spin up on demand four types of VMs:
* Debian-FRR routers for Ps and RRs since these roles demand way less power than a vJunos and are not as "interesting" since they don't interact directly with customers
* vJunos routers (similar to vMX but way more lightweight while performing virtually the same for a lab) for PEs
* VyOS routers for CPEs (will probably leave this for later since my focus is on the SP side itself. So will likely use FRRs for this role for the time being)
* IEC-104 client/master nodes, being just very simple Python scrips making use of existing IEC-104 emulator libraries on a very small Debian VM


I'm starting by adding some initial code, then I'll tweak as I see necessary based on what the Utilities Carrier project requires in the moment.