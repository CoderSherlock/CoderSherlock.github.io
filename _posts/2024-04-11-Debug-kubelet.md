---
title:  "Debug Kubelet"
date:   2024-04-10 03:34:00 -0400
tags: ["Kubernetes", "Kubelet", "Debug"]
author: Pengzhan Hao
cover: '/static/2024-04/kubelet.webp'
---

## Debug logs

Like all others program's debugging, the most straightforward way for newbies and the easiest way for advanced developer is relying on logs. Same to debug `kubelet`, bumping up verbosity to show more logs is the most intuitive approach when facing an issue. Like most component in Kubernetes, `kubelet` uses `klog` for logging and there are 10 verbosity levels(0-9).

TL;DR: Bumping up to level 5 would satisfy most debugging needs.

| Level | Meaning                                                                            | Example                                                                                                                               |
| ----- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| 0     | Always on (Warning, Error, Fatal)                                                  | https://github.com/kubernetes/kubernetes/blob/d9c54f69d4bb7ae1bb655e1a2a50297d615025b5/pkg/kubelet/kubelet.go#L757-L757               |
| 1     | Default level logs when don't want any verbosity                                   | https://github.com/kubernetes/kubernetes/blob/d9c54f69d4bb7ae1bb655e1a2a50297d615025b5/pkg/kubelet/kubelet.go#L2527                   |
| 2     | Most important logs when major operations happen, also the default verbosity level | https://github.com/kubernetes/kubernetes/blob/d9c54f69d4bb7ae1bb655e1a2a50297d615025b5/pkg/kubelet/kubelet.go#L483-L483               |
| 3     | Extended information                                                               | https://github.com/kubernetes/kubernetes/blob/d9c54f69d4bb7ae1bb655e1a2a50297d615025b5/pkg/kubelet/kubelet.go#L2176                   |
| 4     | Debug level                                                                        | https://github.com/kubernetes/kubernetes/blob/d9c54f69d4bb7ae1bb655e1a2a50297d615025b5/pkg/kubelet/kubelet.go#L1731                   |
| 5     | Trace level                                                                        | https://github.com/kubernetes/kubernetes/blob/d9c54f69d4bb7ae1bb655e1a2a50297d615025b5/pkg/kubelet/kubelet.go#L2821-L2821             |
| 6     | Display requested resources                                                        | https://github.com/kubernetes/kubernetes/blob/d9c54f69d4bb7ae1bb655e1a2a50297d615025b5/pkg/kubelet/cm/cgroup_manager_linux.go#L401    |
| 7     | Display HTTP request headers                                                       | https://github.com/kubernetes/kubernetes/blob/d9c54f69d4bb7ae1bb655e1a2a50297d615025b5/pkg/kubelet/logs/container_log_manager.go#L299 |
| 8     | Display HTTP request payload                                                       | https://github.com/kubernetes/kubernetes/blob/d9c54f69d4bb7ae1bb655e1a2a50297d615025b5/pkg/kubelet/prober/prober_manager.go#L192      |

By the time, this note was written. In `kubelet` related code, level 8 was only used in `pkg/kubelet/prober/prober_manager.go` and level 7 was only used in `pkg/kubelet/logs/container_log_manager.go`.  And there are  11 occurrences that level 6 was used, and all of them are not part of workload lifecycle related.

## Further readings
[Inotify watcher leaks in Kubelet](/posts/inotify-watcher-leaks-in-kubelet.html)