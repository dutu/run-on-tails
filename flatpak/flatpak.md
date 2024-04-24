---
layout: page
title: Flatpak
nav_order: 30
---

## Flatpak
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---
### Overview

[Flatpak] is an open-source software utility that provides a sandboxed environment for distributing and running Linux applications.

---
### Install Flatpak

* Make sure **Tails Autostart** utility has been installed. See [Tails Autostart].


* Clone Run-on-Tails GitHub repository:
```shell
$ cd ~/Downloads
$ git clone https://github.com/dutu/run-on-tails.git
```


* Install flatpak software package:
  ```shell
  $ sudo apt update
  $ sudo apt install flatpak
  ```
    * Click **Install Every Time**, when Tails asks if you want to add flatpak to your additional software.


* Add persistent configuration for flatpak applications:
  ```shell
  $ chmod +x ./run-on-tails/flatpak/add_persistence.sh 
  $ ./run-on-tails/flatpak/add_persistence.sh 
  ```
  * Wait for the message `Flatpak installation setup completed successfully.`


---
### How to use it

Flatpak is now installed and flatpak applications can be added with `flatpak install`.

{: .highlight }
> 
> You can launch your Flatpak application from the GNOME desktop using a menu item, which is represented by a .desktop file.
>
> While `flatpak install` does generate a .desktop file, its location, along with the `Icon` and `Exec` fields, must be adjusted to ensure compatibility with Tails OS. This necessity stems from:
>   * The unique architecture of Tails OS: It doesn't define the `XDG_DATA_DIRS` environment variable, causing the Flatpak share directory (where the .desktop and icon files reside) to be omitted from the GNOME search path.
>   * Tails OS's practice of reinstalling additional software packages after each reboot, which takes a few minutes: This process inhibits the GNOME desktop from locating the `flatpak run` (command specified in the .desktop file) post-reboot, resulting in the .desktop file being overlooked.
>
> By relocating the .desktop file to the appropriate directory and adjusting the `Icon` and `Exec` entries, the system will be able to display the correct menu item to launch your application.
>
> We've developed three utilities to simplify these tasks:
>
> * `flatpak-menu-item-copy.sh` identifies the application's .desktop file and copies it to the right location in persistent storage.<br>
    The source .desktop file is first searched for in the persistent application directory and, if not found, in the Flatpak shared directory.
> * `flatpak-menu-item-update-icon.sh` finds the application's icon file and updates the `Icon` entry with its path.<br>
    The icon file is primarily searched for in the persistent application directory and, if not found, in the Flatpak shared directory.
> * `flatpak-menu-item-update-exec.sh` updates the `Exec` entry to point to `flatpak-run.sh`.<br>
     This script creates the `flatpak-run.sh` script that launches the application based on the original .desktop file's `Exec` entry.

---
### Remove Flatpak

* Remove persistent configuration: 
  ```shell
  $ dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
  $ rm $dotfiles_dir/.config/autostart/amnesia.d/flatpak-setup-persistent-apps.sh
  $ persistence_dir="/home/amnesia/Persistent"
  $ rm -fr $persistence_dir/flatpak/utils 
  ```
  
* Remove flatpak package:
  ```shell
  $ sudo apt remove flatpak
  ```

---
[Flatpak]: https://www.flatpak.org/
[Tails Autostart]: ../tails-autostart/tails-autostart.html
