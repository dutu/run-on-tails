---
layout: page
title: Running Tails in virt-manager
description: A guide on how to run Tails in virt-manager
nav_order: 930
---

## Running Tails in virt-manager
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---
### Overview

Official Tails guide [Running Tails from a USB image], includes step 3 **Increase the size of the USB image**. 
However, this is not sufficient. The partition and FAT File System also need to be resized. Follow the steps below to properly prepare the USB image.  

---
### Prepare the USB Image

* [Download Tails as a USB image](https://tails.net/install/download/index.en.html).


* Increase the size of the USB image:
  ```shell
  $ cd ~/Downloads
  $ truncate -s 16GB tails-amd64-6.2.img
  ```


* Attach the Image to a Loop Device:
  ```shell
  $ sudo losetup -Pf --show tails-amd64-6.2.img
  ```
  The command will return a loop device name, e.g. `/dev/loop0`.


* Fix the GPT Partition Table:
  ```shell
  $ sudo gdisk /dev/loop0
  ```
  * In `gdisk`, enter the following commands:
    * **x** to enter the expert menu.
    * **e** to relocate the backup data structures to the end of the disk.
    * **w** to write the changes and exit.


* Resize the partition:
  ```shell
  $ sudo parted /dev/loop0 print
  $ sudo parted /dev/loop0
  (parted) resizepart 1 100%
  ```


* Resize the FAT File System:
  *  Launch **GParted**
  * **Select the loop device** (your image file mounted as a loop device) from the top right dropdown menu.
  * **Right-click the FAT32 partition** you want to resize and choose "Resize/Move."
  * **Adjust the size settings** in the dialog box. You can use the graphical slider or enter specific values for the new size.
  * **Apply the changes** by clicking the green check mark button.


### Create and run the virtual machine

* Execute the steps in section [Running Tails from a USB image], starting with step 3. 

---
[Running Tails from a USB image]: https://tails.net/doc/advanced_topics/virtualization/virt-manager/index.en.html