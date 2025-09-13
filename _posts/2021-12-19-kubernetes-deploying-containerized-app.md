---
layout: post
title: Kubernetes
subtitle: Creating and Deploying a Containerized App
tags: [Google Cloud Platform, GCP, Kubernetes, K8S, Containers, Docker, Java]
comments: true
author: Ani Talakhadze
summary: This guide walks you through creating, testing, and deploying a containerized Java web app to Google Kubernetes Engine (GKE) using Google Cloud Shell and Cloud Code. It covers setting up a local Kubernetes cluster, modifying and viewing your app, and finally deploying it to the cloud—making Kubernetes on GCP approachable for beginners.
---

Many developers are confused when they hear “google cloud platform,” as I was when I first learned about GCP. It’s not unexpected, because even if you visit [cloud.google.com](https://cloud.google.com/), you won’t be able to fully comprehend the platform’s massive content and capabilities. On the one hand, this highlights the potential of cloud computing services, but it also makes it nearly impossible for a newcomer to get started using the platform without assistance.
[
Well](https://cloud.google.com/), why not begin your journey with me today? We’ll work together to clarify all of the steps and procedures, and by the end of the series, you’ll have a lot more confidence in your cloud computing skills, and who knows, you could even start guiding other lost souls like yourself!

In this tutorial, we will create a containerized web app, test it locally, and then deploy it to a Google Kubernetes Engine (GKE) cluster. So grab a cup of coffee and brace yourself for a coding session!

## What is Kubernetes? Why do we need it?  

Kubernetes was introduced in 2014 by Google. Many of you may be curious about the origins of the name Kubernetes, which is also known as K8s, an acronym originating from the eight letters between the letters “K” and “s.” It’s derived from a Greek word that means “pilot” or “orchestrator” — now its logo already makes sense. According to the [official definition](https://kubernetes.io/docs/concepts/overview/), “Kubernetes is a portable, extensible, open-source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation”. To put it differently, it allows us to manage clusters of containerized applications and services.

Cloud-native apps are self-contained, lightweight containers that can be scaled quickly in response to demand. We can isolate the application and its dependencies from the underlying infrastructure by enclosing everything in a container (such as a Docker container). This allows us to run the containerized application in any environment that has the container runtime engine installed. This is where Kubernetes comes into play. Container orchestrations in Kubernetes are significant because they control the lifetime of the containers. That is why, while dealing with cloud-native apps, Kubernetes is so vital and valuable.


## Creating a Web App  

To follow along with this guide, you’ll need a Google Cloud account first. Google Cloud, fortunately for everyone, offers a 90-day free trial period with $300 in free Cloud Billing credits to explore and evaluate its products and services. Who could ask for anything more? Go ahead and make a new account, then return to this page to catch up.

For this tutorial, we’ll be using the Cloud Shell Editor as our development environment. Cloud Shell is a free preloaded online environment, with command-line access for managing your infrastructure and an online code editor for cloud development.

With the default Cloud Shell experience, a preconfigured Compute Engine virtual machine with a Debian-based Linux operating system is created on startup. The environment you work with is a Docker container running on that VM. While your Cloud Shell session is active, the instance persists; after an hour of inactivity, your session is terminated, and the VM is discarded.

To open Cloud Shell, click Activate Cloud Shell button in the upper right part of the page. When you use Cloud Shell for the first time to perform a Google Cloud API request or use a command-line tool that requires credentials, Cloud Shell prompts you with the ‘Authorize Cloud Shell’ dialog. To authorize the tool to use your credentials to make calls, click Authorize.

<figure>
  <img src="https://i.imgur.com/ZxjmFHc.png" alt="Trulli" style="width:100%">
  <figcaption><center>Activating and authorizing Cloud Shell
</center></figcaption>
</figure>

Click Open Editor to open Cloud Shell Editor.

<figure>
  <img src="https://i.imgur.com/4oK3Kih.png" alt="Trulli" style="width:100%">
  <figcaption><center>Opening Cloud Shell Editor
</center></figcaption>
</figure>

Launch the Cloud Code menu from the status bar and select New Application.

<figure>
  <img src="https://i.imgur.com/1Z0IRSk.png" alt="Trulli" style="width:100%">
  <figcaption><center>Starting a new application from the Cloud Code menu
</center></figcaption>
</figure>

Select the Kubernetes application option as the type of sample app. From the list of sample Kubernetes apps, select the Java: Hello World option, and finally, select a folder for your app location and then click Create New Application.

Cloud Shell Editor creates a new workspace for your program. With the explorer view, you may access your app once it reloads. The structure of the “Hello World” project is relatively simple, with only one main class. It consists of a single Deployment and its associated Service. A web server is included in the deployment, which renders a basic webpage. You can take a look at the classes and their basic functionality, however, exploring them in detail is out of the scope of this tutorial.

<figure>
  <img src="https://i.imgur.com/s71tRH9.png" alt="Trulli" style="width:100%">
  <figcaption><center>Structure of the “Hello World” project
</center></figcaption>
</figure>


## Building and Testing the App  

Now that we have created our app, we can run it in a local Kubernetes cluster in Cloud Shell. In your terminal, run this command to start your local minikube cluster:

```bash
minikube start
```

<figure>
  <img src="https://i.imgur.com/z7YuOyX.png" alt="Trulli" style="width:100%">
  <figcaption><center>Starting a local Kubernetes cluster
</center></figcaption>
</figure>

After your cluster is set up, the following message will be displayed:

<figure>
  <img src="https://i.imgur.com/x4w3sZT.png" alt="Trulli" style="width:100%">
  <figcaption><center>Successful setup of the cluster
</center></figcaption>
</figure>

Next, we will build and run this app. Launch the Cloud Code menu from the status bar, Select Run on Kubernetes, and then confirm that you want to use the minikube context.

<figure>
  <img src="https://i.imgur.com/FR4mn1x.png" alt="Trulli" style="width:100%">
  <figcaption><center>Running the app on Kubernetes in the minikube context
</center></figcaption>
</figure>

The Output panel displays the progress as your app is built and deployed:

<figure>
  <img src="https://i.imgur.com/93j8DFr.png" alt="Trulli" style="width:100%">
  <figcaption><center>The Output Panel
</center></figcaption>
</figure>

After your app is built, which should take a couple of minutes, you can launch it using the link displayed in your Output panel.

<figure>
  <img src="https://i.imgur.com/7S4cUfD.png" alt="Trulli" style="width:100%">
  <figcaption><center>Link for launching the app
</center></figcaption>
</figure>

Congratulations! You have just run your first app on Kubernetes using Cloud Code.


## Modifying the App  

To review what the Hello World app consists of, refer to the diagram in its readme.md file. At a high level, it consists of:

- A basic HelloWorldController web app that returns a templated “It’s running!” response to all received requests.

<figure>
  <img src="https://i.imgur.com/w2ggWvG.png" alt="Trulli" style="width:100%">
  <figcaption><center>HelloWorlController class
</center></figcaption>
</figure>

- A load balancer service hello.service.yaml, that exposes the app by describing a Kubernetes service.

<figure>
  <img src="https://i.imgur.com/29I8Bum.png" alt="Trulli" style="width:100%">
  <figcaption><center>hello.service.yaml file
</center></figcaption>
</figure>

We can modify our HelloWorldController to print “It’s redeployed!”. The file saves automatically.

<figure>
  <img src="https://i.imgur.com/f5pLaiF.png" alt="Trulli" style="width:100%">
  <figcaption><center>Modifying HelloWorldController
</center></figcaption>
</figure>

You can monitor your app’s progress as it’s rebuilt, using the Output panel. After your app finishes building and deploying, launch your app by clicking the link in the Output panel or refresh the tab where you opened your app.


## Viewing App Logs  

There is a quite handy feature called Log Viewer to monitor your app’s logs while it’s running. You can launch it by opening the Command Palette (Ctrl + Shift + P) and then typing Cloud Code: View Logs.

<figure>
  <img src="https://i.imgur.com/8RddXAF.png" alt="Trulli" style="width:100%">
  <figcaption><center>Launching app logs from Command Palette
</center></figcaption>
</figure>

Specify the Deployment or Pod filters to view the logs for our app, java-hello-world:

<figure>
  <img src="https://i.imgur.com/HebfftS.png" alt="Trulli" style="width:100%">
  <figcaption><center>Configuring Log Viewer
</center></figcaption>
</figure>

Refresh the app in the browser. To view the newly generated logs in the Log Viewer, click the Logs refresh button.


## Creating a Google Kubernetes Engine Cluster  

We’ve been running our app locally thus far. It’s time to deploy our application to a remote cluster!

Projects are a way for Google Cloud to group together related resources. We must first create a project before we can create a GKE cluster. You can select an existing project, but let’s create a new one for the sake of this tutorial.

Open the Navigation menu and then click Kubernetes Engine. Click Create and click Configure under the standard cluster.

<figure>
  <img src="https://i.imgur.com/E7AQgt2.png" alt="Trulli" style="width:100%">
  <figcaption><center>Creating a new Kubernetes Engine
</center></figcaption>
</figure>

In Cluster basics, enter a name and zone for the cluster. To create the cluster, click Create. It takes a few minutes for the cluster to provision.

<figure>
  <img src="https://i.imgur.com/sLYKPeg.png" alt="Trulli" style="width:100%">
  <figcaption><center>Configuring Kubernetes Engine
</center></figcaption>
</figure>

Click the Cloud Code — Kubernetes icon in the navigation bar. Hover over the Kubernetes Explorer and then click + Add a cluster to the KubeConfig.

<figure>
  <img src="https://i.imgur.com/2adAb9A.png" alt="Trulli" style="width:100%">
  <figcaption><center>Adding a cluster to the KubeConfig
</center></figcaption>
</figure>

Select Google Kubernetes Engine. Select your recently created cluster from the list.


## Deploying Our App to a GKE cluster  

Finally, let’s deploy our app to the new cluster. From the Cloud Code menu, accessible using the status bar, select Run on Kubernetes. Confirm your newly created cluster as the context for your app. Confirm the default option for your image registry.

<figure>
  <img src="https://i.imgur.com/C85uq13.png" alt="Trulli" style="width:100%">
  <figcaption><center>Running the app on a remote Kubernetes cluster with the default image registry
</center></figcaption>
</figure>

After the app is successfully deployed, you can launch it with the link displayed in the Output pane.

<figure>
  <img src="https://i.imgur.com/LMYWxX4.png" alt="Trulli" style="width:100%">
  <figcaption><center>Page after successfully deploying the app
</center></figcaption>
</figure>

<center>* * *</center>

At the end of this short tutorial, you already know how to create a sample Kubernetes app, build/test/edit this app on a local Kubernetes cluster, view and navigate your app’s logs, create a GKE cluster and deploy an app to GKE. Pretty impressive, isn’t it?

There’s a lot more to learn about Google Cloud Platform, so stay tuned and don’t miss out on my next blogs!