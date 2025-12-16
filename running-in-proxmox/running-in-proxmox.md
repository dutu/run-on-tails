---
layout: page
title: Running Tails in Proxmox
description: A guide on how to run Tails in Proxmox
nav_order: 920
---

## Running Tails in Proxmox
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---
### Overview

[Proxmox Virtual Environment] is a complete open-source platform for virtualization.

Running Tails from a USB image in Proxmox allows you to use a Persistent Storage in a virtual machine.

{: .important }
> [Running Tails inside a virtual machine has various security implications]

All commands in this instruction are run as root on the Proxmox host.

---
### Download and verify Tails image


* Check and set the latest version of Tails
  ```bash
  VERSION=7.3.1
  ```


* Download Tails as a USB image:
  ```bash
  cd /tmp
  wget -O tails-amd64.img https://download.tails.net/tails/stable/tails-amd64-$VERSION/tails-amd64-$VERSION.img
  ```


* Download the signature file:
  ```bash
  wget -O tails-amd64.img.sig https://tails.net/torrents/files/tails-amd64-$VERSION.img.sig
  ```


* Download and import the Tails signing key
  ```bash
  wget https://tails.net/tails-signing.key
  gpg --import tails-signing.key
  ```
Expected output (example):
  ```console
  gpg: key 0xDBB802B258ACD84F: public key "Tails developers <tails@boum.org>" imported
  gpg: Total number processed: 1
  gpg:               imported: 1
  ```


* Verify the image
  ```bash
  gpg --verify tails-amd64.img.sig tails-amd64.img
  ```
Expected result, you should see something like:
  ```console
  gpg: Signature made ...
  gpg:                using RSA key DBB802B258ACD84F
  gpg: Good signature from "Tails developers <tails@boum.org>"
  ```
You may also see:
  ```console
  gpg: WARNING: This key is not certified with a trusted signature!
  ```
This warning is normal. It only means you haven’t manually verified the key fingerprint yet.


* Verify the key fingerprint
  ```bash
  gpg --fingerprint DBB802B258ACD84F
  ```
Expected fingerprint (must match exactly):
  ```console
  A490 D0F4 D311 A415 3E2B  B7D4 DBB8 02B2 58AC D84F
  ```

---
### Resize Tails USB image

* Resize the Tails USB image:
  ```bash
  qemu-img resize -f raw tails-amd64.img 16G
  ```
{: .note }
> Minimum allowed by Tails: 7200M<br>
> Recommended: 8G or more


* Verify the resize:
  ```bash
  qemu-img info tails-amd64.img
  ```
Expected result:
  ```console
  image: tails-amd64.img
  file format: raw
  virtual size: 16 GiB (17179869184 bytes)
  disk size: 1.9 GiB
  ```


---
### Create the virtual machine

* Pick a free VM ID (for example `301`) and VM storage (for example `vm-os` or `local`).
  ```bash
  VMID=301
  STORAGE=vm-os
  ```


* Create the VM:
  ```bash
  qm create $VMID \
    --name tails-usb \
    --machine q35 \
    --bios ovmf \
    --memory 4096 \
    --cores 4 \
    --cpu host \
    --net0 virtio,bridge=vmbr0 \
    --ostype l26
  ```


* Import the USB image into Proxmox storage
  ```bash
  qm importdisk $VMID tails-amd64.img $STORAGE
  ```
This creates something like:
  ```console
  unused0: successfully imported disk 'vm-os:vm-301-disk-0'
  ```


* Get imported disk image path:
  ```bash
  pvesm path $STORAGE:vm-$VMID-disk-0
  DISK_PATH=$(pvesm path $STORAGE:vm-$VMID-disk-0)
  ```


* Attach the image as a USB removable disk:
  ```bash
  qm set $VMID --args "-device qemu-xhci,id=xhci \
    -drive id=usbdisk,file=$DISK_PATH,format=raw,if=none,cache=writeback \
    -device usb-storage,bus=xhci.0,drive=usbdisk,removable=on"
  ```


* Fix boot order (will let OVMF handle boot discovery):
  ```bash
  qm set $VMID --delete boot
  ```
{: .note }
> This setup intentionally does not use a persistent EFI variables disk (NVRAM).<br>
> This matches the behavior of a real live USB device and avoids PXE boot issues.


* Do not use ballooning with Tails:
  ```bash
  qm set $VMID --balloon 0
  ```


* Verify VM config:
  ```bash
  qm config $VMID
  ```
Example printout:
  ```console
  args: -device qemu-xhci,id=xhci     -drive id=usbdisk,file=/dev/zvol/slowpool/vm-os/vm-301-disk-0,format=raw,if=none,cache=writeback     -device usb-storage,bus=xhci.0,drive=usbdisk,removable=on
  balloon: 0
  bios: ovmf
  boot:  
  cores: 4
  cpu: host
  machine: q35
  memory: 4096
  meta: creation-qemu=10.1.2,ctime=1765902838
  name: tails-usb
  net0: virtio=BC:24:11:FE:76:7C,bridge=vmbr0
  ostype: l26
  smbios1: uuid=0f36b186-e060-4c01-865e-0ea8655634ba
  unused0: vm-os:vm-301-disk-0
  vmgenid: 5ddae391-ce59-41fb-bf81-93cbfd3218b7
  ```
{: .note }
> There is `unused0: vm-os:vm-301-disk-0`<br>
> This is expected and correct.<br>
> The disk is intentionally not attached as scsi0, it is consumed directly by QEMU via<br>
> `file=/dev/zvol/slowpool/vm-os/vm-301-disk-0`.<br>
> ⚠️ Do NOT delete `unused0`<br>
> ⚠️ Do NOT attach it as scsi/sata<br>


---
### Run the virtual machine

* Start the VM:
  ```bash
  qm start $VMID
  ```
 

* Open the console from the Web UI.


* Create Persistent Storage (inside Tails), once booted:
  **Welcome Screen → Persistent Storage**


* Reboot when prompted

Persistence now survives reboots inside Proxmox.

---
{: .highlight }
Last tested: Tails 7.3.1 in Proxmox 9.1.2.

---
[Proxmox Virtual Environment]: https://www.proxmox.com/en/products/proxmox-virtual-environment/overview
[Running Tails inside a virtual machine has various security implications]: https://tails.net/doc/advanced_topics/virtualization/index.en.html#security
