---
layout: post
title:  "Some of my previews experiment works"
date:   2016-10-28 12:27:33 -0400
categories: Research
---
# Time series


## 2016-10

### Time Experiment of rsync

Patch is based on rsync with version 3.1.2. \[[Rsync](https://download.samba.org/pub/rsync/rsync-3.1.2.tar.gz)\|[Patch](/static/2016-10/rsync/rsync-3.1.2-time.patch)\]

#### How to collect data

Basically, everything of transmission time and computation time will be output with overall time will be printed on the console.
But we also need some bash script to collect data through different size of random size and with different modification through them.

- Start from 8K to 64M, modify at beginning, \[[Bash script](/static/2016-10/rsync/small2Big_change_at_begin.sh)\]
- Start from 8K to 64M, modify at last, \[[Bash script](/static/2016-10/rsync/small2Big_change_at_last.sh)\]
- Start from 8K to 64M, modify at random place with a (slow) python script, \[[Bash script](/static/2016-10/rsync/small2Big_change_at_anyplace.sh)\|[Python program](/static/2016-10/rsync/addbyte.py)\]

### Time Experiment of seafile


