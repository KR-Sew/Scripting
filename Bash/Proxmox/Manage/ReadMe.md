# <img width="35" height="35" src="https://img.icons8.com/fluency/48/proxmox.png" alt="proxmox"/> Creates Proxmox VM

[![Proxmox](https://img.shields.io/badge/proxmox-proxmox?style=flat&logo=proxmox&logoColor=%23E57000&labelColor=%232b2a33&color=gray)](https://learn.microsoft.com/en-us/windows/wsl/about)
[![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=flat&logo=gnubash&logoColor=white&logoSize=auto&labelColor=black)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

That script is for creating a vm on **Proxmox VE** host

## 📂 Description

- 📂 [Create **PVE** VM](./create-pve-vm.sh)
  - Make it executable:

    ```bash
    chmod +x create-pve-vm.sh
    ```

  - **Debian** or **Ubuntu** example

    ```bash
      sudo ./create-pve-vm.sh \
       --vmid 192 \
       --name debian12 \
       --os linux \
       --storage local-zfs \
       --iso local:iso/debian-12.11.0-amd64-netinst.iso \
       --cores 4 \
       --memory 8192 \
       --disk-size 64G \
       --bridge vmbr0 \
       --onboot
    ```

  - For one of your shared **LVM** storages, it could instead be:

    ```bash
      sudo ./create-pve-vm.sh \
       --vmid 192 \
       --name ubuntu-server \
       --os linux \
       --storage VG-iDs2 \
       --efi-storage local-zfs \
       --iso local:iso/ubuntu-24.04.3-live-server-amd64.iso \
       --cores 4 \
       --memory 8192 \
       --disk-size 64G
    ```

  - The `EFI` disk can be on separate storage from the main VM disk. Ensure that storage is accessible wherever the VM may run.

**Windows Server** example:
- **Windows Setup** does not natively include every **Proxmox** `VirtIO` storage driver, so attach the `VirtIO` driver `ISO`. **Proxmox** documents installing the `VirtIO` driver before or while moving the **Windows** boot disk to `VirtIO SCSI`.

    ```bash
    sudo ./create-pve-vm.sh \
        --vmid 193 \
        --name ws2025-test \
        --os windows \
        --storage local-zfs \
        --iso local:iso/Windows_Server_2025.iso \
        --virtio-iso local:iso/virtio-win.iso \
        --cores 4 \
        --memory 8192 \
        --disk-size 100G \
        --bridge vmbr0 \
        --onboot
    ```

  - During Windows installation, when no disk appears:
    - Select Load driver.
    - Browse the `VirtIO` CD.
    - Load the appropriate vioscsi driver.
    - After installation, install the full `VirtIO` guest tools package and enable the `QEMU` **Guest Agent** service.
  - **Windows 11** example:

    ```bash
     sudo ./create-pve-vm.sh \
        --vmid 194 \
        --name win11-test \
        --os windows11 \
        --storage local-zfs \
        --iso local:iso/Windows_11.iso \
        --virtio-iso local:iso/virtio-win.iso \
        --cores 4 \
        --memory 8192 \
        --disk-size 100G \
        --bridge vmbr0 \
        --onboot
    ```

  - This adds:

    ```text
      Machine: q35
      BIOS: OVMF
      EFI disk: 4 MB
      Secure Boot keys: enrolled
      TPM: 2.0
    ```

---

- 📄[README.md](ReadMe.md) # Project documentation

---

🔙 [back to 📂 Scripting](../)
