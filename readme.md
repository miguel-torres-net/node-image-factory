# node-image-factory

This project supports a separate Utilities Carrier Lab.

My goal is to be able to spin up on demand four types of VMs:
* Debian-FRR routers for Ps and RRs since these roles demand way less power than a vJunos and are not as "interesting" since they don't interact directly with customers
* vJunos routers (similar to vMX but way more lightweight while performing virtually the same for a lab) for PEs
* VyOS routers for CPEs
* IEC-104 client/master nodes, being just very simple Python scrips making use of existing IEC-104 emulator libraries on a very small Debian VM


I'm starting by adding some standard boilerplate bash, then I'll tweak as I see necessary based on what the Utilities Carrier project requires in the moment.