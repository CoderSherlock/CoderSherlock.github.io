---
title:  "EDDL: How do we train neural networks on limited edge devices - PART 2"
date:   2021-10-31 13:01:14 -0400
tags: ["Research", "Edge computing"]
author: Pengzhan Hao
cover: '/static/2024-04/eddl2.webp'
mathjax: true
---

In the last post, part1, our idea of distributed learning on edge environment was generally addressed.
I introduced the reason why edge distributed learning is needed and what improvements it can achieve.
In this post, I will talk about our motivation study and how our framework works.
  
## How does data support us training on edge?

Before designing and implementing our framework, we first need confirmation that training on edge resource-limited devices is worthwhile.
We were using a malware detection neural network to show why a small, customized neural network is better.

We collected 32000+ mobile apps feature as global data.
With these data records, we trained a multilayer perceptron called "PerNet" to determine whether a given feature belongs to a benign or malware app.
We called this **detection**.
As well, PerNet can also classify malware apps into different types of attacks.
We called this **classification**.
The global model can achieve 93% above recall rate and 96.93% above accuracy.

With all these data, we selected two community app usage sub-dataset for local model generations.

- Large categories (Scenario 1)
    We chose the 5 largest categories of apps, including entertainment, tools, brain&Puzzle, Lifestyle, and Education, as well as the 5 largest malware categories.
    All together, 12000+ apps were included in this sub-dataset, almost 50 to 50 between benign and malware.

- Campus-community categories (Scenario 2)
    We chose the 5 most downloaded categories from college students as benign groups, as well as a similar amount of 5 malware categories.
    To ensure that malware apps are included in 5 benign categories, we also considered synthesizing some other malware apps within categories of 5 most downloaded(benign) categories.

With these two types of sub-dataset, we used the same PerNet to generate multiple local models.
Under each scenarios experiment, we compared global and local models on the preserved test dataset.
In all classification performances, local beat global in every scenario.
In detection performances, local also share the same accuracy as global does.

![Inference results](/static/2021-10/t.3_inference_result.png)

In summary, local models were trained on special occasions.
Under the same circumstance, a global model can achieve no better accuracy than local models.
The reason why local is better might be because of overfitting.
I believe this issue also be considered in the machine learning communities that they brought [transfer learning](https://en.wikipedia.org/wiki/Transfer_learning),
a technique to optimize global models to special scenarios but performing more training to a global model once it's shipped to local.

## Design and Implementation

### Overall design

The basic EDDL distributed training setup consists of 3 parts.
**EDDL training cluster**, a device cluster that consists of edge or mobile devices that are participating in training.
**EDDL manager**, the initial driver program that works as collect training data, relay data to training devices and initial training clusters.
**Training data entry (TDE)**, a data storage for all training data.

### Dynamic training data distribution

Existing distributed DNN training solutions usually statically partition training data among workers.
It can be a problem when the training node joins and exits.
We designed our framework that can dynamically distribute training data during learning.
Before every training batch started, a batch of TDE will be sent to devices.

In our experiments, we found that by applying this design, overall training time was shortened by doing.
Especially in large amount devices cases, this optimization can be 50% less than statically divided.

### Scaling up cluster size

Our framework was designed to have both sync and async parameter aggregation.
Asynchronous aggregation can allow a high outcome of training batch but with a sacrifice or converge time.
Synchronous aggregation allows a quick converge time in epochs, however can't ensure performance when there's a struggler worker.

As showed in experiments, we chose sync as default because the converging time is dominant in overall training time.
But, we also considered the possibilities of that async with more workers can achieve similar overall training time.

We introduced a formula to determine whether adding more training nodes can help or not.
Here we used bandwidth usage coefficient (BUC) as

$$ BUC = \dfrac{n}{T_{sync}} $$

In this formula, $$n$$ is the number of devices, and $$T_{sync}$$ is the transmission time of parameters.
With an increasing number of workers, n increase linearly but transmission time does not.
When $$BUC$$ increases, the cluster can speed up training time by adding workers.
Otherwise, adding more workers won't help with overall training time.

### Adaptive leader role splitting

The idea of role splitting is simple that a device can work as a worker as well leader.
The advantage of doing this is straightforward that we can transfer 1 less parameter and training time will be shortened.

However, in our current settings, it can't perform much better help since only 1 leader role is in a cluster.
We can benefit from this in our future works.

### Overall architecture

![Implementation](/static/2021-10/f.5_Impl_leader_worker.png)

Details were given in the image.

### Prototype hardware and software

EDDL was designed to be run on two single-board computer embedded platforms.
One such platform is [ODROID-XU4](https://www.hardkernel.com/shop/odroid-xu4-special-price/), which is equipped with a 2.1/1.4 GHz 32-bit ARM processor and 2GB memory.
The other platform is the [Raspberry Pi 3 Model B board](https://www.raspberrypi.com/products/raspberry-pi-3-model-b/), which comes with an ARM 1.2 GHz 64-bit quad-core processor and 1GB memory.

The operating system running on the above platforms is Ubuntu 18.04 with Linux kernel 4.14.
We used [Dlib](http://dlib.net/), a C++ library that provides implementations for a wide range of machine learning algorithms.
We chose the Dlib library because it is written in C/C++, and can be easily and natively used in embedded devices.
