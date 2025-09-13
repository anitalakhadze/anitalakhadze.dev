---
layout: post
title: Kubernetes
subtitle: An Overview
tags: [Kubernetes, K8s, K8s cluster, pods, node]
comments: true
author: Ani Talakhadze
summary: This post offers a clear overview of Kubernetes, explaining the core problems it solves for deploying and scaling containerized applications. It covers key concepts like clusters, control plane, nodes, and pods, and breaks down the architecture that enables zero-downtime deployments, easy scaling, and efficient resource management for modern software projects.
---

Knowing K8s will set you apart from a lot of other software engineers since there is a lot of demand for people who know K8s right now. Let’s briefly discuss the basic concepts and architectural features that make Kubernetes such a nice tool for any developer!


## What is the problem Kubernetes is attempting to solve?  

To appreciate the solution Kubernetes offers, we must first imagine the problems it is attempting to solve. Consider a basic Spring Boot application that responds to a request with a hard-coded string. We may have a virtual machine with 8GB of RAM and four CPUs. We’d want to deploy our app container there.

Obviously, we will certainly have a large number of people accessing our application, thus we will need to scale. Another node with an identical setup and application will be required.

Imagine that we have a new version of our app that we want to deploy. Before we can destroy the first version, we’ll need to establish a new node. So, wait a minute… Are you beginning to see the problem we’re about to confront? We’d need 12 cores and 24GB of RAM if we just had three containers, which isn’t something a smart developer would agree to. This is where Kubernetes enters the picture.


## What is the solution Kubernetes is offering to us?  

Kubernetes, K8s for short, is a platform that allows us to manage containerized applications and services. It enables us to deploy new versions of applications several times a day, as often as you wish, scales up and down in response to demand, offers zero-downtime deployments, rollbacks, and much more. Doesn’t that sound really cool?

Let’s have a look at the basic modules of K8s and briefly discuss their importance.


## What is a cluster?  

A cluster is a collection of nodes, each of which can be a virtual computer (VM) or a physical system, hosted on AWS, Azure, GCP, or even on-premises.

To put it simply, Kubernetes just coordinates a cluster of computers that are connected to work as a single unit. You can deploy your containerized apps to a cluster without tying them specifically to individual machines thanks to the abstractions in K8s.

Apps must be packaged in a way that decouples them from particular hosts in order for this new deployment strategy to be usable: they must be containerized, which is why Docker will be required.


## Kubernetes cluster architecture  

K8s cluster consists of two types of resources: the Control Plane which coordinates the cluster and the Nodes that are the workers running the applications.

<figure>
  <img src="https://i.imgur.com/cExR5X0.png" alt="Trulli" style="width:100%">
  <figcaption><center>Image from <a href="https://d33wubrfki0l68.cloudfront.net/283cc20bb49089cb2ca54d51b4ac27720c1a7902/34424/docs/tutorials/kubernetes-basics/public/images/module_01_cluster.svg">Kubernetes</a> tutorials
</center></figcaption>
</figure>

According to official [Kubernetes docs](https://kubernetes.io/docs/tutorials/kubernetes-basics/_print/#pg-7df66040311338d6098ebeab43ba9afb), the Control Plane is in charge of coordinating all operations in your cluster, including application scheduling, maintaining the intended state of applications, scaling applications, and rolling out new updates. It manages the cluster and the nodes that are used to host the running applications. All of the decisions are made here.

There are usually more than one worker node and one master node in a cluster so that if one node goes down, etcd member and control plane instances won’t be lost and redundancy won’t be compromised.

You inform the control plane to start the application containers when you deploy apps on Kubernetes. The containers are scheduled to run on the cluster’s nodes by the control plane. The Kubernetes API, which the control plane exposes, is used by the nodes to communicate with the control plane. End users can also communicate with the cluster directly via the Kubernetes API.


## The control place  

The Control Plane within the master node is made of several components communicating with each other via the API Server.:

- The API Server — frontend to K8s Control Plane. All communications, either external or internal, go through the API Server. It exposes RESTful API on port 443 and in order for you to talk to API, authentication and authorization checks are performed.
- Cluster Store — stores the configuration and state of the entire cluster.
Scheduler — watches for new workloads/pods and assigns them to a node based on several scheduling factors (being healthy, having enough resources, port availability, and other important criteria).
- Controller Manager — A Daemon that manages the control loop. It is basically a controller of controllers (Node Controller, ReplicaSet, Endpoint, Namespace, Service Accounts, and others) that are watching the API server for changes.
- Cloud Controller Manager — responsible for interacting with the underlying cloud provider (AWS, Azure, or GCP) regarding load balancers, storage, or instances.


## The nodes  

A node is a VM or a physical computer that serves as a worker machine in a Kubernetes cluster. All of the heavy lifting work, such as executing your apps, takes place on the worker node.

<figure>
  <img src="https://i.imgur.com/8wYAwi6.png" alt="Trulli" style="width:100%">
  <figcaption><center>Image from <a href="https://d33wubrfki0l68.cloudfront.net/5cb72d407cbe2755e581b6de757e0d81760d5b86/a9df9/docs/tutorials/kubernetes-basics/public/images/module_03_nodes.svg">Kubernetes</a> tutorials
</center></figcaption>
</figure>

A Worker Node provides a running environment for our applications. It has 3 main components:

- Kubelet — technology that applies, creates, updates, and destroys containers on a Kubernetes node, manages the node, and helps it to communicate with the control plane; receives Pod definitions from the API Server; interacts with Container Runtime to run containers associated with the Pod; reports Node and Pod state to the master node.
- Container Runtime — responsible for pulling images from container registries, starting, or stopping containers, so, it basically abstracts container management for Kubernetes.
- Kube Proxy — an agent that runs on every node through DaemonSets. It is responsible for local cluster networking, providing each node with its own unique IP address, and routing network traffic to load-balanced services.


## Pods in Kubernetes  

Now to fully understand the K8s working model, we should briefly discuss pods — the smallest basic execution units of Kubernetes. Put simply, it is a K8s abstraction that represents a group of one or more app containers (such as Docker), and some shared resources (shared storage (Volume), networking (unique cluster IP address), etc.) for these containers.

A Pod always runs on a Node. One Node can have multiple pods, and the K8s control plane automatically handles scheduling the pods across the Nodes in the cluster, taking into account the available resources on each Node.

When we apply a Deployment on K8s, that Deployment will create Pods with containers inside them (as opposed to creating containers directly). Each Pod is tied to the Node where it is scheduled and remains there until termination or deletion.

<figure>
  <img src="https://i.imgur.com/wJIObzC.png" alt="Trulli" style="width:100%">
  <figcaption><center>Image from <a href="https://d33wubrfki0l68.cloudfront.net/fe03f68d8ede9815184852ca2a4fd30325e5d15a/98064/docs/tutorials/kubernetes-basics/public/images/module_03_pods.svg">Kubernetes</a> tutorials
</center></figcaption>
</figure>

The containers in a Pod share an IP Address and port space and run in a shared context on the same Node. Our containers will communicate with one another by using localhost. The pod has its IP address, which means that if another pod wishes to communicate with it, it will use that address.

<center>* * *</center>

That’s it! We have discussed all the basic concepts you may need for understanding Kubernetes and its mission.

If you want to try out more practical stuff and find out about deploying your Docker image in a local Kubernetes cluster, you can have a look at my another [article](https://anitalakhadze.github.io/2022-01-14-kubernetes-deploying-docker-locally/).

Happy coding and stay tuned for my future blogs!