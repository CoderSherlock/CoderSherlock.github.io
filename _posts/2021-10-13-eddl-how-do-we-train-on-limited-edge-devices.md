---
title:  "EDDL: How do we train neural networks on limited edge devices - PART 1"
date:   2021-10-13 16:53:20 -0400
tags: ["Research", "Edge computing"]
author: Pengzhan Hao
cover: '/static/2024-04/eddl1.webp'
---
This post introduces our previous milestone in project "Edge trainer", as the paper "EDDL: A Distributed Deep Learning System for Resource-limited Edge Computing Environment." was published.
As the first part of the introductions, I focus only on the motivation and summary of our works.
More details in design and implementation can be found in late posts.

<img src="/static/2021-10/edgelearn-1.png" height="250">
<!--more-->

## Why do we need training on edge?

Cloud is not trustworthy anymore. More and more facts support that breach on the cloud happens frequently than before.
Nowadays, with more generated personal sensitive data has been uploaded to the cloud center, tech companies know better to someones than the user.
  
Researchers, no matter in the industry on academia, are working in a way that still learning from users' data but also keeping raw sensitive data under users' control.
Many publications have already shown the feasibility of only sharing the after-trained model instead of raw data.
One recent popular study on this is google's [federated learning](https://ai.googleblog.com/2017/04/federated-learning-collaborative.html).
  
During investigating this problem, we found that letting end-user train their data is safe, but sacrifice efficiency.
Since one end device has limited resources, training time and power consumption can be disappointing.
We believe there must have leverage between privacy and efficiency in some target scenarios.

Fortunately, we observed that users who belong to the same campus, plant, firm, and community always share similar interests.
Therefore, these co-located users have similar demands in using AI-involved routines.
Also, co-located users are easily targeted by the same type of threats, such as ransomware to financial practitioners.

Think about this, sending features of a new malware app to cloud services to train neural networks used by antivirus programs.
This process may take a long time and a small number of samples may not be recognized by the global neural networks model.
A customized local model trained and deployed on the edge can successfully counter the problem.
With edge training as a supplement to the cloud training can achieve better response time and let the whole system more flexible.

## Why training on edge is hard?

Since all co-located users' devices can be used for edge training, issues and challenges occur as deploying this distributed system.

The first challenge is **struggling workers**.
Training devices are heterogeneous, from limited IoT cameras to high-end media centers with powerful GPUs.
They are not designed to do machine learning.
So, a good edge-based distributed learning framework must be able to handle a variety of speeds in training tasks.

The second challenge is how to **scale up** clusters.
On a campus, thousands and more devices may contribute computing resources to the same training tasks.
However, these devices may be located far no matter in physical or in network topology.
The question of how can we well use them well, without struggling with endless transmission time remains a challenge.

The third issue is frequently **joining and exiting** of devices.
We can't rely on each device to faithfully work on training tasks rather than their original workload.
Smartly schedule work balance and handle join/exit issues also need under consideration.

## Our proposal

- Dynamic training data distribution and runtime profiler

    We design a dynamic training data distribution mechanism that helps both the first and the third challenges.
    Preprocessing data can be transmitted without leakage of raw and sensitive information.
    This can help struggling workers who can train small batches in order to upload parameters with a similar training time.
    Also, for extremely slow devices, join and exit of devices cases, dynamic data distribution and profiler can help with keeping global training parameters from pollution and staleness.

    To counter heterogeneity, more approaches were applied in our later research.
    More details were introduced to the runtime profiler in the later works.

- Asynchronous and synchronous aggregation enabled

    In our findings, asynchronous and synchronous parameter update have their pros and cons.
    Keeping sync all the time leads to struggling worker issues unsolvable.
    However, async's harm to accuracy and convergence time also needs attention.
    To carefully choose between these two update policies at the runtime is what we proposed to make use of their own advantages.

- Leader role splitting

    The idea is to let worker devices with higher bandwidth take leader-role during training.
    Parameter updating does not require much computation but only needs a great of bandwidth.
    Devices with sufficient bandwidth can also work as virtual leader devices.
    This approach helps minimize physical devices we used and more leaders can further scale up workers' limits.
