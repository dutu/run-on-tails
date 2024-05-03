---
layout: page
title: Bisq
nav_order: 50
---

## Bisq
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---
### Overview

[Bisq] is and open-source desktop software, Bisq provides a peer to peer bitcoin exchange experience. Buy and sell bitcoin for fiat (or other cryptocurrencies) privately and securely using Bisq's peer-to-peer network.

![bisq.png](bisq.png)


---
### Install Bisq

* Open a _Terminal_ window:  choose **Applications ▸ Utilities ▸ Terminal**


* Clone Run-on-Tails GitHub repository:
```shell
$ cd ~/Downloads
$ git clone https://github.com/dutu/run-on-tails.git
```


* Setup Bisq installation:
  ```shell
  $ chmod +x ./run-on-tails/bisq/setup-installation.sh 
  $ ./run-on-tails/bisq/setup-installation.sh 
  ```
  * Wait for the message `Bisq installation setup completed successfully.`


---
### How to use it

* Choose **Applications ▸ Other ▸ Bisq**

  {: .note }
  [Bisq Data directory] is relocated to the Persistent Storage at `/home/amnesia/Persistent/bisq/Bisq`, so that your wallet, keys, etc. are not lost every time Tails shuts down.  
  On the other hand, Bisq application installation is done entirely in memory. Therefore, Bisq must be reinstalled after every Tails boot.
  The installation is done automatically when you launch Bisq through the desktop menu icon.


---
### Backup User Data

* While Bisq is closed, copy your [Bisq Data directory] located at `/home/amnesia/Persistent/bisq/Bisq` to a backup location.


---
### Remove Bisq

* Open a _Terminal_ window:  choose **Applications ▸ Utilities ▸ Terminal**


* Remove persistent configuration:
  ```shell
  $ persistence_dir="/home/amnesia/Persistent"
  $ rm -fr $persistence_dir/bisq/utils
  $ rm -f $persistence_dir/bisq/*.deb*
  ```

{: .important }
Your [Bisq Data directory] located at `/home/amnesia/Persistent/bisq/Bisq` is not deleted.
This directory contains important files, including your BTC and BSQ wallet files.  
You should copy your [Bisq Data directory] to a backup location before deleting it manually. 

### References

* [Running Bisq on Tails]

---
[Bisq]: https://bisq.network/
[Bisq Data directory]: https://bisq.wiki/Data_directory
[Running Bisq on Tails]: https://bisq.wiki/Running_Bisq_on_Tails
