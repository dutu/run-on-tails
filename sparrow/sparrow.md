---
layout: page
title: Sparrow Bitcoin Wallet
description: A guide on how to install and run Sparrow Bitcoin Wallet on Tails
nav_order: 70
---

## Sparrow Bitcoin Wallet
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}


---
### Overview

[Sparrow] is an open-source Bitcoin wallet focused on security, privacy, and usability. It provides detailed, user-friendly information about transactions and UTXOs, supporting financial self-sovereignty.

![sparrow.png](sparrow.png)

---
### Install the latest version of Sparrow

* Open a _Console_:  choose **Apps ▸ System Tools ▸ Console**

* Clone Run-on-Tails GitHub repository:
```shell
$ cd ~/Downloads
$ git clone https://github.com/dutu/run-on-tails.git
```

* Setup Sparrow:
```shell
$ chmod +x ./run-on-tails/sparrow/setup-installation.sh 
$ ./run-on-tails/sparrow/setup-installation.sh 
```
  * Wait for the message `Sparrow installation setup completed successfully.`

 ---
### How to use it

* Choose **Applications ▸ Other ▸ Sparrow**

{: .note }
If you use a public server, set Proxy URL to `127.0.0.1:9050`.


---
### Backup your wallet

* While Sparrow is closed, copy your Sparrow wallet directory located at `/live/persistence/TailsData_unlocked/dotfiles/.sparrow/wallets` to a backup location.


---
### Remove Sparrow

If you want to remove a currently installed version of Sparrow  (eg. in case of a clean new install)

* Open a _Console_:  choose **Apps ▸ System Tools ▸ Console**

* Remove Sparrow application files:
  ```shell
  $ rm -fr /home/amnesia/Persistent/Sparrow/
  $ rm -f /live/persistence/TailsData_unlocked/dotfiles/.local/share/applications/sparrow.desktop
  ```
  
{: .important }
Sparrow data directory which contains wallet and configuration files is not deleted.
It is located at `/live/persistence/TailsData_unlocked/dotfiles/.sparrow/`

---
> Last tested: Sparrow 2.3.1 on Tails 7.3.1

---
[Sparrow]: https://www.sparrowwallet.com/
