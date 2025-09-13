---
layout: post
title: Kubernetes
subtitle: Deploying a Docker Image to a Local Cluster
tags: [Kubernetes, Deployment, Minikube, Docker, Kubectl]
comments: true
author: Ani Talakhadze
summary: This tutorial shows you how to deploy a Docker image to a local Kubernetes cluster using Minikube. It walks through setting up the environment, configuring nodes, creating deployment and service YAML files, and accessing your running application—making it easy to get hands-on experience with Kubernetes on your own machine.
---

In this tutorial, I want to show you how to deploy a docker image to a local Kubernetes cluster directly from your computer. This will hugely increase your coding confidence. So grab your favorite snacks and keep the rhythm!


## Setting Up the Environment   

We will need [Docker](https://docs.docker.com/get-started/overview/) to package our application into a container and run it on a K8s cluster.

To get started with setting up a local K8s cluster, we can use [Minikube](https://minikube.sigs.k8s.io/docs/), which is a lightweight K8s implementation that creates a VM on our local machine and deploys a simple cluster containing only one node.

Minikube is a great tool to have in your kit. It is available for all operating systems and the Minikube CLI provides basic helpful operations, including starting, stopping, deleting the cluster, or checking the status.

After having installed Docker and Minikube, you’re ready to go.


## Setting Up the Local Cluster  

Let’s get down to business and start 2 nodes with the following command:

```bash
minikube start --nodes=2
```

This is going to take some time. You will see it pulling a base image and configuring other operations. The following will appear as the success message at the end:

```
Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

We can check the minikube status with the following command:

```bash
minikube status
```

We will see something like this:

```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

minikube-m02
type: Worker
host: Running
kubelet: Running
```

The first, minikube, is the Control Plane — master node which supports the host, Kubelet API, and Kube configs. The second is the worker node.

If we check the docker processes via

```bash
docker ps
```

we will see that we have 2 containers — one for the master and one for the worker node:

```
CONTAINER ID   IMAGE                                 COMMAND                  CREATED         STATUS         PORTS                                                                                                                                  NAMES
9db0a1b4ceab   gcr.io/k8s-minikube/kicbase:v0.0.28   "/usr/local/bin/entr…"   2 minutes ago   Up 2 minutes   127.0.0.1:64998->22/tcp, 127.0.0.1:64994->2376/tcp, 127.0.0.1:64996->5000/tcp, 127.0.0.1:64997->8443/tcp, 127.0.0.1:64995->32443/tcp   minikube-m02
4a010f289ac7   gcr.io/k8s-minikube/kicbase:v0.0.28   "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes   127.0.0.1:64967->22/tcp, 127.0.0.1:64968->2376/tcp, 127.0.0.1:64965->5000/tcp, 127.0.0.1:64966->8443/tcp, 127.0.0.1:64964->32443/tcp   minikube
```


## Interacting With the Cluster  

When it comes to interacting with the cluster from our local machine, kubectl, the Kubernetes command-line tool, will come in handy. It uses the K8s API to interact with the cluster. We can utilize it to deploy apps, examine and change resources, debug and view logs, and a lot more.

If you want to interact with the cluster, type:

```bash
kubectl get nodes
```

You will see that we have two nodes:

```
NAME           STATUS   ROLES                  AGE   VERSION
minikube       Ready    control-plane,master   28m   v1.22.3
minikube-m02   Ready    <none>                 27m   v1.22.3
```


## Creating Kubernetes Deployment Configuration  

So, we already have a Kubernetes cluster up and operating. On top of that, we can now deploy our containerized app. To do so, we’ll need to create a Kubernetes Deployment configuration that tells K8s how to generate and update application instances. The K8s control plane will schedule the app instances contained in that Deployment to run on specific Nodes in the cluster once we’ve created it.

Deployments can grow the number of replica pods, allow for the controlled release of new code, or roll back to a previous deployment version if necessary. Deployment Controller continually monitors the instances when they are created, and if one goes down or is destroyed, it is replaced with another instance on another Node in the cluster. This solves the issue of machine failure or maintenance.

You can use any editor of your choice to create a Deployment. I will be using Visual Studio Code for this. You can easily set it up, then install the Kubernetes extension, which will provide auto completion when creating Deployment for Kubernetes.

<figure>
  <img src="https://i.imgur.com/QtVMYbo.png" alt="Trulli" style="width:100%">
  <figcaption><center>Kubernetes extension for Visual Studio Code
</center></figcaption>
</figure>

Go ahead and create deployment.yml somewhere in your file system. Next, we will set up a basic configuration. Type ‘dep’ and let it auto-complete:

<figure>
  <img src="https://i.imgur.com/LqueOIx.png" alt="Trulli" style="width:100%">
  <figcaption><center>deployment.yml file
</center></figcaption>
</figure>

It will look something like this:

<figure>
  <img src="https://i.imgur.com/Rw5zOCS.png" alt="Trulli" style="width:100%">
  <figcaption><center>Kubernetes Deployment configuration
</center></figcaption>
</figure>

We will insert the config for the number of replicas, modify the memory spec, container port and replace the image with a public image from my Docker registry — anitalakhadze/spring_hello_world:

<figure>
  <img src="https://i.imgur.com/2Bf7u33.png" alt="Trulli" style="width:100%">
  <figcaption><center>Modifying the Kubernetes Deployment
</center></figcaption>
</figure>

Now what we want to do is to create a service that will allow us to access the pods. You can think of this service as a load balancer. Don’t forget three dashes and type in “serv”:

<figure>
  <img src="https://i.imgur.com/ww3Ym3x.png" alt="Trulli" style="width:100%">
  <figcaption><center>Kubernetes Service configuration
</center></figcaption>
</figure>

It will look like the following:

<figure>
  <img src="https://i.imgur.com/Qg8tTqo.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

The 8080 port is the one container will be listening to and 80 is the port of the service. So, this selector “myapp” will match to the pod which has the same name in its template metadata labels.

Now the last thing is to change the spec a little bit to expose random ports on both nodes.

<figure>
  <img src="https://i.imgur.com/3JOVJEK.png" alt="Trulli" style="width:100%">
  <figcaption><center>Exposing random ports on both nodes
</center></figcaption>
</figure>

You can read more about the networking model of Kubernetes [here](https://kubernetes.io/docs/tutorials/services/connect-applications-service/).


## Applying Kubernetes Deployment  

Now, let’s see all the pods available in our cluster (all pods in all namespaces):

```bash
kubectl get pods -A
```

You will see pods that the Control Plane is made up of:

```bash
NAMESPACE     NAME                               READY   STATUS    RESTARTS        AGE
kube-system   coredns-78fcd69978-cdxkm           1/1     Running   1 (16m ago)     7d16h
kube-system   etcd-minikube                      1/1     Running   1 (16m ago)     7d16h
kube-system   kindnet-4n24p                      1/1     Running   28 (16m ago)    7d16h
kube-system   kindnet-6q689                      1/1     Running   206 (16m ago)   7d16h
kube-system   kube-apiserver-minikube            1/1     Running   1 (16m ago)     7d16h
kube-system   kube-controller-manager-minikube   1/1     Running   1 (16m ago)     7d16h
kube-system   kube-proxy-4lvh2                   1/1     Running   1 (16m ago)     7d16h
kube-system   kube-proxy-mbpj2                   1/1     Running   1 (16m ago)     7d16h
kube-system   kube-scheduler-minikube            1/1     Running   1 (16m ago)     7d16h
kube-system   storage-provisioner                1/1     Running   2 (7m57s ago)   7d16h
```

Now if you run

```bash
kubectl get pods
```

you will get the following message:

```
No resources found in default namespace.
```

That’s because although we have created our deployment configuration, we haven’t applied it. To apply our deployment.yml configuration, we have to provide the following command:

```bash
kubectl apply -f deployment.yml
```

When we applied the Deployment with the above command, K8s created a Pod to host our application instance. After that, you will see the following message:

```
deployment.apps/myapp created
service/myapp created
```

<figure>
  <img src="https://i.imgur.com/SPPFleJ.png" alt="Trulli" style="width:100%">
  <figcaption><center>Image from Kubernetes tutorials
</center></figcaption>
</figure>

Now if you check the pods again, this time you will see two running pods:

```
NAME                    READY   STATUS    RESTARTS   AGE
myapp-8d8d79856-ml2jh   1/1     Running   0          3m5s
myapp-8d8d79856-vx7gs   1/1     Running   0          2m15s
```


## Accessing Our Application  

In order for us to access our application, let’s type:

```bash
kubectl get svc
```

We will see that we have a service myapp of type NodePort with the random port assigned to it forwarding to 80 which will, on its hand, forward the request to our container to port 8080, according to the specs we wrote in our file.

```
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        4m2s
myapp        NodePort    10.96.114.46   <none>        80:30676/TCP   7s
```

To access this service, let’s type:

```bash
minikube service myapp
```

Give it a second and it will open a web browser window with your application:

<figure>
  <img src="https://i.imgur.com/q1eMx1R.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

You can check the detailed information in the terminal:

<figure>
  <img src="https://i.imgur.com/IS5xuVJ.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

<center>* * *</center>

That’s it! We have our Spring Boot application up and running on the local Kubernetes cluster. How cool is that?

If you are interested in Kubernetes’ core infrastructure, you can have a look at my previous article [here](https://anitalakhadze.github.io/2022-01-17-kubernetes-overview/).

Also, if you are interested in reading more about Cloud-Native Development and deploying a containerized app on Kubernetes from Google Cloud Platform, you can go ahead and read about it in my another article [here](https://anitalakhadze.github.io/2021-12-19-kubernetes-deploying-containerized-app/).

Don’t miss the future blogs to find out more about Kubernetes and other interesting stuff out there. Stay tuned!


