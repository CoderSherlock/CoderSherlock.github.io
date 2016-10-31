---
layout: post
title:  "Using charles proxy to monitor mobile SSL traffics"
date:   2016-10-27 22:50:33 -0400
categories: Network
---

In this blog, I will generally talk about how to use proper tools to monitor SSL traffics of a mobile devices. Currently, I only can dealing with those SSL traffics which use an obviously certification. Some applications may not using system root cert or they doesn't provide us a method to modify their own certs. For these situation, I still didn't find a good solutions for it. But I'll keep updating this if I get one.  
My current solution is using AP to forward all SSL traffic to a proxy, [charles proxy](https://www.charlesproxy.com/) is my first choice (Prof asked). It's a non-free software which still update new versions now. So mainly, I'll talk about how to charles SSL proxy.

### Preparations
- Monitor device situation: Linux Machine with wireless adapter
- Download the newest version(4.0.1) of charles
- Target android devices with root privilege


