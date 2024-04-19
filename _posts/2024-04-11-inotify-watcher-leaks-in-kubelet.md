---
title: Inotify watcher leaks in Kubelet
date: 2024-04-18 16:35 -0400
description: 
cover: '/static/2024-04/kubelet_inotify_leak_logo.png'
category: 
tags: ["Kubernetes", "Kubelet", "Debug", "Inotify"]
published: true
sitemap: true
permalink: 
author: Pengzhan Hao
---

## Symptom
Recently, I faced an issue where Kubelet on a node reported error message failed to create file descriptors.

```bash
error creating file watcher: too many open files
error creating file watcher: no space left on device
```

After short checking, I found the node has `max_user_watches` of 10000, but the `TotalinotifyWatches` is beyond this value. (P. S still not sure why watcher can initiate more than cap). In order to find which process occupied the most watchers. I used following command[^flbit_ino] to find it out.

```bash
echo -e "COUNT\tPID\tUSER\tCOMMAND"; sudo find /proc/[0-9]*/fdinfo -type f 2>/dev/null | sudo xargs grep ^inotify 2>/dev/null | cut -d/ -f 3 | uniq -c | sort -nr | { while read -rs COUNT PID; do echo -en "$COUNT\t$PID\t"; ps -p $PID -o user=,command=; done}

COUNT	PID	USER	COMMAND
7491	8412	root /home/kubernetes/bin/kubelet --v=2 --cloud-provide=gce --experi
2620	1	root /sbin/init
....
```

Surprisingly, Kubelet initiated more than 7000 inotify watchers. I assumed there was an inotify leakage in Kubelet.
## Leakage check

### Clean Kubelet
To better understand the situation, I created a clean cluster with only 1 clean node on GKE. Roughly 70 inotify watchers were there. I created a single nginx pod and the number increased by 3. Theoretically, these 3 watchers are used by Kubelet to monitor any changes on `rootfs `, `kube-api-access` and `PodSandbox`. But to verify it, we need to check more details on which inodes are monitored by Kubelet. 
### Check inotify file descriptors
To do so, let's take a look how to track a single inotify file descriptor. Opened processes' `fdinfo` folder, we can examine each or them to find an inotify fd. 

```bash
# Find kubelet pid
ps -aux | grep kubelet
KPID=2430

# File the an example fd
sudo ls /proc/2430/fdinfo

0 1 10 11 12 13 14 2 3 4 5 6 7 8 9

...

sudo cat /proc/2430/fdinfo/8

pos:	0
flags:	02004000
mnt_id:	15
ino:	1057
inotify wd:1 ino:3f327 sdev:800001 mask:fc6 ignored_mask:0 fhandle-bytes:8 fhandle-type:1 f_handle:27f30300e5059ea2
```

This is very confusing, so I rely on `man proc`[^man_proc] to understand every piece of them. In given fd, the needed information to continue sit in the last line. It's an inotify entry represents the 1 file or folder to be monitored. And the most useful data is `ino:3f327` which represents the inode number of target file (in hexadecimal). And `sdev:800001`, which represents the ID of device where the inode sit on, and it's also in hex.

Using `lsblk`, I can see there's only 1 disk I'm using on the node, so finding the target file would be easy.

```bash
# Cast to decimal
ino=3f327
dec="$((16#${ino}))"

# Find the target file
loc="debugfs -R 'ncheck ${dec}' /dev/sda1"
sudo eval $loc 2>/dev/null

debugfd 1.46.5 (30-Dec-2021)
Inode	Pathname
258855	/etc/srv/kubernetes/pki/ca-certificates.crt
```

Put all processes above into one single script, I can retrieve all target files, that would help to understand if there's a real leakage. Also, I count the unique inode amount, this could also help to know which inode are monitored multiple times.

```bash
cat << EOF | sudo tee -a test.sh
echo "kubelet pid="${PID}
in_fds=$(find /proc/${PID}/fdinfo -type f 2>/dev/null | xargs grep ^inotify | cut -d " " -f 3 | cut -d ":" -f 2)
echo ${in_fds}
echo "Count: $(find /proc/${PID}/fdinfo -type f 2>/dev/null | xargs grep ^inotify | wc -l)"

uniq_fds=$(echo "${in_fds[@]}" | sort | uniq)
echo ${uniq_fds}

while read -r element;
do
  count=$(echo "${in_fds[@]}" | grep -o "${element}" | wc -l)
  dec="$((16#${element}))"
  loc="debugfs -R 'ncheck ${dec}' /dev/sda1"
  loc=$(eval $loc 2>/dev/null | tail -1 | cut -d " " -f 4)
  printf "%-6s %-10s %-6s %s\n" "${element}" "${dec}" "${count}" "${loc}"
done <<< "${uniq_fds}"
EOF

sudo bash test.sh

kubelet pid=2430
3f327 3f321 ...
Count: 120
1 10b 1259 128a ...
1	1	72	Inode	Pathname
10b	267	1	267	/etc/systemd/system/multi-user.target.wants/snapd.service
...
```

The given results are consists by following parts:
- One line for get Kubelet pid
- One line for all target inode numbers
- One line for tell how many unique inode (120)
- One line of sorted target
- Following 120 lines, each of them represents a unique inode number, its decimal number, count, another time of decimal number and the target file path.

I used the same script to the problematic node, and it showed the following result. In summary, most Kubelet watchers were targeting `ino:1 `. And there are 6649 targets files, which likely to be leakage, because there were only 150 pods on this pod. Unfortunately, `debugfs` can't find any target files, so the output showed as meaningless string `"Inode Pathname"`.

```
kubelet pid=8412
...
Count: 7491
...
1	1	6649	Inode Pathname
```

### Bad apple
Why `debugfs` can't help anymore? The reason is simple, each cgroup for a pod is using its own rootfs. This means the watcher are somehow residing on different rootfs and using independent inode index.  There are some other ways to do it, I choose the most common tool `grep` to find out.

```
sudo grep / -inum 1
/home/kubernetes/containerized_mounter/rootfs/dev
/home/kubernetes/containerized_mounter/rootfs/proc
...
/home/kubernetes/containerized_mounter/rootfs/var/lib/kubelet/pods/5325873d-f2a0-48df-83e2-0b911df2f77f/volumes/kubernetes.io~projected/kube-api-access-227jg
...
/dev
/boot/efi
...
```

This turns things easy, because I can just use pod ID to compare between running pods to find out if there are any terminated pods are there. And it did show there's some non-existence pods still being watched somehow.

## What to expect next

- [How Kubelet leaked inotify watchers?]()
- [debugfs]()

## References

[^flbit_ino]: [Fluentbit error "cannot adjust chunk size" on GKE](https://stackoverflow.com/a/76712244)
[^man_proc]: [proc(5)](https://manpages.courier-mta.org/htmlman5/proc.5.html)
[^list_ino]: [Listing the files that are being watched by `inotify` instances](https://unix.stackexchange.com/a/646113)