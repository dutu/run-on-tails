---
layout: page
title: Signal Desktop Messenger
nav_order: 30
---

## Signal Desktop Messenger
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---
### Overview

[Signal] is a privacy-focused messaging application that offers end-to-end encryption for secure text messages, voice calls, and video calls.

![signal.png](../../images/signal.png)

{: .highlight }
For privacy, the application's configuration is not persistent and resets with every Tails reboot.<br>
As a result, after each reboot you need to link Signal to your account.<br>
Although possible, the process for setting up a persistent configuration isn't covered in this instruction.


---
### Install Signal

* Make sure **Flatpak** has been installed. See [Flatpak].


* Open a _Terminal_ window:  choose **Applications ▸ Utilities ▸ Terminal**


* Install Signal:
  ```shell
  $ torsocks flatpak install flathub org.signal.Signal
  ```


* Configure persistence:
  ```shell
  ```

---
### Start Signal

* Choose **Applications ▸ Other ▸ Signal**

---
### For the Future: Update Signal

* Open a _Terminal_ window:  choose **Applications ▸ Utilities ▸ Terminal**


* Update the application:
  ```shell
  $ torsocks flatpak update org.signal.Signal
  ```

---
### Remove Signal

* Open a _Terminal_ window:  choose **Applications ▸ Utilities ▸ Terminal**


* Remove the application:
  ```shell
  $ torsocks flatpak uninstall org.signal.Signal
  ```


* Remove unused runtimes and SDK extensions:
  ```shell
  $ torsocks flatpak uninstall --unused
  ```


* Remove menu entry and utility files:
  ```shell
  $ dotfiles_dir="/live/persistence/TailsData_unlocked/dotfiles"
  $ rm $dotfiles_dir/.local/share/applications/org.signal.Signal
  $ rm /home/amnesia/.local/share/applications/org.signal.Signal
  $ persistence_dir="/home/amnesia/Persistent"
  $ rm -fr $persistence_dir/org.signal.Signal
  ```
  
--- 
[Signal]: https://signal.org/
[Flatpak]: ../flatpak/flatpak.html