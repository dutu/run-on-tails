---
layout: page
title: Tails Autostart
nav_order: 810
---

## Tails Autostart
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---
### Overview

[Tails Autostart] is a utility script that automatically starts scripts/applications on Tails bootup.

This utility facilitates other applications to work properly.


---
### Install Tails Autostart

* Open a _Terminal_ window:  choose **Applications ▸ Utilities ▸ Terminal**


* Clone Run-on-Tails GitHub repository:  
  ```shell
  $ cd ~/Downloads
  $ git clone https://github.com/dutu/run-on-tails.git
  ```

* Run installation script:
  ```shell
  $ chmod +x ./run-on-tails/tails-autostart/install.sh
  $ ./run-on-tails/tails-autostart/install.sh
  ```
  * Wait for message `Tails Autostart installation completed successfully.`

---
### How to use it

* add any scripts to `/live/persistence/TailsData_unlocked/dotfiles/.config/autostart/amnesia.d` to execute them on startup as user `amnesia`
* add any scripts to `/live/persistence/TailsData_unlocked/dotfiles/.config/autostart/root.d to` execute them on startup as user `root`


---
### Remove Tails Autostart

* Remove Tails Autostart files:
  ```shell
  $ rm /live/persistence/TailsData_unlocked/dotfiles/.config/autostart/tails-autostart.desktop
  $ rm -fr /live/persistence/TailsData_unlocked/dotfiles/.config/autostart/tails-autostart
  ```
  > Scripts in `autostart/amnesia.d` and `autostart/root.d` intended to run on startup will remain in place. However, with the removal of Tails autostart, they will no longer be triggered at Tails startup.  


[Tails Autostart]: https://github.com/dutu/tails-autostart