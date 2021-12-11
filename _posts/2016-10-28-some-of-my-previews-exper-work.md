---
title:  "Some of my previews experiment works: 2016"
date:   2016-10-28 12:27:33 -0400
tags: ["Research", "Log", "Miscellanies"]
author: Pengzhan Hao
---
This blog contains only some basic record of my works. For some details, I will write a unique blog just for some specific topics.
<!--more-->

# 2016-10

## Time Experiment of rsync

Patch is based on rsync with version 3.1.2. \[[Rsync](https://download.samba.org/pub/rsync/rsync-3.1.2.tar.gz)\|[Patch](/static/2016-10/rsync/rsync-3.1.2-time.patch)\]

### How to collect data

Basically, everything of transmission time and computation time will be output with overall time will be printed on the console.
But we also need some bash script to collect data through different size of random size and with different modification through them.

- Start from 8K to 64M, modify at beginning, \[[Bash script](/static/2016-10/rsync/small2Big_change_at_begin.sh)\]
- Start from 8K to 64M, modify at last, \[[Bash script](/static/2016-10/rsync/small2Big_change_at_last.sh)\]
- Start from 8K to 64M, modify at random place with a (slow) python script, \[[Bash script](/static/2016-10/rsync/small2Big_change_at_anyplace.sh)\|[Python program](/static/2016-10/rsync/addbyte.py)\]

## Time Experiment of seafile

Patch is based on seafile 5.1.4. You can find the release from [seafile official repo](https://github.com/haiwen/seafile/releases). You may follow official compile instructions from [here](https://manual.seafile.com/build_seafile/linux.html). \[[Patch **no longer avaiable, new version at following sections**]()\]  

### How to collect data

We also need everything be done using scripting. But this time I only design added some distance between two increasing files' sizes. 

- Start from 8K to 16M, 4 times increasing, modify at beginning/ at 1024 different places with python script. \[[Bash Script](/static/2016-11/seafile/trans.sh)\|[Python program](/static/2016-11/seafile/addbyte.py)\]
- After using this auto testing script, everything of output will be marked in log files of seafile, which located in **~/.ccnet/log/seafile.log**  
- We need to use this simple awk code and vim operation to extract data.

~~~~bash
# CDC: content defined chucks
# HUT: Http upload traffic
# ALL: overall time of one commit & upload
awk '/CDC|HUT|ALL/ {print $4,$5}' ~/.ccnet/log/seafile.log > results.stat
~~~~


### Install Seafile on odroid xu

Due to failure of my cross-compile to seafile on android. I used develop board as a replacement experiment platform for ARM-seafile testing. I used a [odroid xu](http://www.hardkernel.com/main/products/prdt_info.php?g_code=G137510300620) as hardware standard. Because all I need is an ARM platform, only an ARM-Ubuntu is enough for me. But develop prototype on a board is much fun than coding, I won't address much this time. But I'll start a blog telling some really cool stuff I made for a strange aim.   
  
To install a ubuntu with GUI is my all preparation work. I found to way to do this.  
  
- [armhf](http://www.armhf.com/boards/odroid-xu/) is a website for arm-based ubuntu. It has a detailed instruction to follow at [here](http://www.armhf.com/boards/odroid-xu/odroid-sd-install/). They also provide ubuntu 12.04/ 14.04 and debian 7.5 to choose. But unfortunately odroid xu's hdmi output doesn't supported by ubuntu native firmware. So install ubuntu-desktop might can't be boot up for video output. 
  
- Burn images is much easy to install a pre-complied ubuntu system. I found this on odroid xu's forum, which contains xubuntu image \[[download](http://odroid.in/ubuntu_14.04lts/ubuntu-14.04lts-xubuntu-odroid-xu-20140714.img.xz)\] for odroid xu. With this image, you just need to use dd command to write whole system mirror into sdcard.

~~~~bash
# If .img end with xz, use this command to uncompress first
unxz ubuntu-14.04lts-xubuntu-odroid-xu-20140714.img.xz    
# Burn image into SD-card
sudo dd if=ubuntu-14.04lts-xubuntu-odroid-xu-20140714.img of=/dev/sdb bs=1M conv=fsync
sync
~~~~

# 2016-11

## Android Kernel 

### How to build an Android Kernel?

Generally, I won't tell anything in this parts, just mark some related links, and point out some mistakes or error solutions.

- [Google Official Guide](http://source.android.com/source/building-kernels.html#figuring-out-which-kernel-to-build)
-- If you don't have AOSP sources, you have to download prebuilt toolchains which recommended in this guide might not be correct. Use following links to choose your fitting tools.
--- [ASOP git root](https://android.googlesource.com/?format=HTML), under sub class "/platform/prebuilts/gcc"

- [Packing and Flashing a Boot.img](https://softwarebakery.com/building-the-android-kernel-on-linux) **[highly recommend]**

# 2016-12

## Android Kernel

### How to compile with ftrace?

If we want to debug under android, ftrace is a great tool for working. But, ftrace is not available in android if we used default configure file. Android kernel configuration is in **arch/arm64/kernel/configs**. We need to add few lines under that.

~~~~bash
CONFIG_STRICT_MEMORY_RWX=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_PERSISTENT_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_PREEMPT_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_STACK_TRACER=y
~~~~

### How to extract android images: Dump an image

If we want to hold a rooted status after flashing boot, we need to extract an image from android devices. We can first use following command to find which blocks belongs to. According to some references, [this article](http://forum.xda-developers.com/showthread.php?t=2450045) provide three ways to dump an image, I picked one for easy using.

~~~~bash
adb shell
ls -al /dev/block/platform/$SOME\_DEVICE../../by-name # {Partitions} -> {Device Block}

# dump file
su
dd if=/dev/block/mmcblk0p37 of=/sdcard/boot.img
~~~~
