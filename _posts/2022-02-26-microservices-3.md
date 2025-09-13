---
layout: post
title: Microservices [Part 3]
subtitle: With Maven, Spring Boot and Docker
gh-repo: anitalakhadze/microservices_practice
gh-badge: [star, fork, follow]
tags: [Microservices, Spring Boot, Maven, Docker, PostgreSQL, Java]
comments: true
author: Ani Talakhadze
summary: This entry in the microservices series explains how to use a service registry—specifically, Eureka Server—to manage and connect multiple Spring Boot microservices. It covers setting up Eureka Server and clients, registering services, and implementing load-balanced communication, making your architecture scalable and resilient as your application grows.
---

In [part 1](https://anitalakhadze.github.io/2022-02-09-microservices-1/) and [part 2](https://anitalakhadze.github.io/2022-02-23-microservices-2/) of the microservices series, we spent some time building two simple microservices — Student and Plagiarism and established HTTP communication between them.

However, that may not be a good solution when your application needs to scale and you have multiple instances running. In such a case, a microservice would need to know about all the existing ports to that application. This can become quite a complex issue and turn into a nightmare.

In this tutorial, I will show you how to solve that problem using Service Registry. The link to the source code repository will be added at the end of this tutorial.


## Eureka Server and Clients  

We won’t go into many details here but to mention briefly, according to the [glossary definition](https://avinetworks.com/glossary/service-discovery/#:~:text=Service%20discovery%20is%20the%20process,of%20networks%20by%20identifying%20resources.), Service Discovery is the process of automatically detecting devices and services on a network.

In Spring Boot, an application holding the information about all client-service applications is called a Eureka Server. The microservices can be referred to as Eureka Clients in this context.

To put it very simply, clients register themselves to the server and the latter knows the exact information of where the service is running — the host, as well as the port. When the microservices want to connect with each other, they will communicate via this server.

In our case, the first thing a Student microservice should do is to register itself as a client to the Eureka Server. Plagiarism instances should do the same too. If the Student microservice decides to talk to Plagiarism via HTTP, the first thing it does is to send a Service Discovery request to find out where Plagiarism is located. The server will return the address for the instance (or one of the instances) and then, the request will go to that specific instance of Plagiarism.

You can see that Eureka Server plays a very important role in this whole game of communication. If it goes down for any reason, the connection between all these microservices will be lost. This is why it is very important to keep the Eureka Server up and running at all costs.


## Spring Cloud Dependency   

You can navigate to Spring’s official web page and take a look at all the features Spring Cloud offers. Right now, let’s get started by adding Spring Cloud Dependency to our project.

Open the main pom.xml file and add the following dependency in the dependencyManagement section to enable each microservice to pick just the dependency it wants:

```xml
<dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-dependencies</artifactId>
  <version>${spring.cloud-version}</version>
  <type>pom</type>
  <scope>import</scope>
</dependency>
```

Declare the spring cloud version inside the properties section (the version may be different for you):

```xml
<spring.cloud-version>2020.0.5</spring.cloud-version>
```

Reload the file to apply changes and let’s move on to setting up Service Discovery.


## Configuring Eurika Server 

In this section, we will build a service that will be responsible for service discovery, solving the problem of the ports, and connecting our microservices with each other.

Create a new module called eurekaserver inside the project:

<figure>
  <img src="https://i.imgur.com/YOgPFJB.png" alt="Trulli" style="width:100%">
  <figcaption><center>Creating a new module for the eureka server inside the project
</center></figcaption>
</figure>

Open the pom.xml file of this newly created module and add the following dependency:

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
    </dependency>
</dependencies>
```

If you press the little blue button next to the dependencies

<figure>
  <img src="https://i.imgur.com/uJZhUJh.png" alt="Trulli" style="width:100%">
  <figcaption><center>Navigation to the parent library
</center></figcaption>
</figure>

you will navigate to spring-cloud-netflix-dependencies of the corresponding version (because of the dependency we added in the parent’s pom.xml file):

<figure>
  <img src="https://i.imgur.com/3o5Uen6.png" alt="Trulli" style="width:100%">
  <figcaption><center>Spring cloud netflix dependencies, version 3.1.1
</center></figcaption>
</figure>

Now that we have the dependency, create a new package com.anita.eurekaserver inside the java folder. Then create a EurekaServerApplication class and annotate it with @EnableEurekaServer:

```java
package com.anita.eurekaserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
    
}
```

Add application.yml inside the resources folder and paste the following lines inside:

```yaml
spring:
  application:
    name: eureka-server

server:
  port: 8765
  
eureka:
  client:
    fetch-registry: false
    register-with-eureka: false
```

Add a custom banner.txt file if you wish:

<figure>
  <img src="https://i.imgur.com/s6Wp7it.png" alt="Trulli" style="width:100%">
  <figcaption><center>Custom banner for the eureka server module
</center></figcaption>
</figure>

When the application starts on port 8765, open the web browser and navigate to that port. You will see a web page representing a Eureka Dashboard, giving information about the service itself, including the instances currently registered with Eureka (which are none at the moment as we have not told our microservices to connect to this server).

<figure>
  <img src="https://i.imgur.com/BHvGej3.png" alt="Trulli" style="width:100%">
  <figcaption><center>Eureka Dashboard
</center></figcaption>
</figure>

This page does not give a lot of information right now but the sections will be updated as we register our services to the Eureka Server.


## Configuring Eurika Clients  

Leave the Eureka Server up and running and let’s start with configuring the Student microservice. Open its pom.xml file and add the following dependency:

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```

Open the main StudentApplication class and annotate it with @EnableEurekaClient:

```java
package com.anita.student;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableEurekaClient
public class StudentApplication {

    public static void main(String[] args) {
        SpringApplication.run(StudentApplication.class, args);
    }

}
```

Open application.yml and add the following configuration at the end of the file:

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8765/eureka
```

Start the StudentApplication to see that everything works fine. From the console logs, you can see that the Discovery Client has been started:

<figure>
  <img src="https://i.imgur.com/mv8MuvB.png" alt="Trulli" style="width:100%">
  <figcaption><center>Logs notifying about Discovery Client
</center></figcaption>
</figure>

If you check the web page, you will see that the instances section has been updated too:

<figure>
  <img src="https://i.imgur.com/dVYpXo5.png" alt="Trulli" style="width:100%">
  <figcaption><center>Updated instances section on the Eureka Dashboard
</center></figcaption>
</figure>

The name of the application on the dashboard comes from the application.yml file so, giving sensible names to them will greatly help you in the future to differentiate among the applications on the web page:

<figure>
  <img src="https://i.imgur.com/2BrW6bO.png" alt="Trulli" style="width:100%">
  <figcaption><center>Declaring application name inside the application.yml file
</center></figcaption>
</figure>

Now go back to IntelliJ and open up the configuration, duplicate StudentApplication and modify the program arguments field:

<figure>
  <img src="https://i.imgur.com/n2mSCre.png" alt="Trulli" style="width:100%">
  <figcaption><center>Application configuration menu
</center></figcaption>
</figure>

<figure>
  <img src="https://i.imgur.com/YCpCFlq.png" alt="Trulli" style="width:100%">
  <figcaption><center>Duplicating the StudentApplication
</center></figcaption>
</figure>

<figure>
  <img src="https://i.imgur.com/AXOSOhS.png" alt="Trulli" style="width:100%">
  <figcaption><center>Modifying the name and program arguments for the new configuration
</center></figcaption>
</figure>

Run the StudentApplication 2 and reload the web page. The number of availability zones will be increased to 2 as we have two instances of StudentApplication(you will also notice that the server maintains the addresses of each of the instances):

<figure>
  <img src="https://i.imgur.com/FSZ6les.png" alt="Trulli" style="width:100%">
  <figcaption><center>Increased number of availability zones on the Eureka Dashboard
</center></figcaption>
</figure>

We don’t need the second instance of StudentApplication anymore, so you can stop it and remove the configuration.

Now, repeat the same process for the Plagiarism module. Modify its pom.xml(add eureka client dependency),application.yml(add eureka service configuration) and PlagiarismApplication (add an annotation for enabling eureka client) files in the same way.

Now if you start all the applications and reload the page, you will see one instance of Student and one for Plagiarism:

<figure>
  <img src="https://i.imgur.com/68dVqZ3.png" alt="Trulli" style="width:100%">
  <figcaption><center>Instances of Student and Plagiarism on Dashboard
</center></figcaption>
</figure>


## Load Balance Requests  

At the moment, the Student makes a network call to Plagiarism in StudentService class. The main reason for using Service Discovery is exactly to remove the need for that. We let the Eureka Server handle that information and we only need the name of the application we want to connect to: "http://PLAGIARISM/api/v1/plagiarism-check/{studentId}",

The name PLAGIARISM will be resolved to the corresponding IP address.

Go to Student’s application.yml file and modify ddl-auto setting from update to create-drop(of course, we don’t want to do this in production environments where you want to keep data). Duplicate the PlagiarismApplication from the configuration, restart Student and Plagiarism, open Postman, and send the following request to the Student service:

```json
{
    "firstName": "Ani",
    "lastName": "Talakhadze",
    "email": "talakhadzeani@gmail.com"
}
```

We will have an internal error because of an unknown internal exception:

<figure>
  <img src="https://i.imgur.com/tkKhNw1.png" alt="Trulli" style="width:100%">
  <figcaption><center>Internal server error in Postman while sending a request
</center></figcaption>
</figure>

Actually, that’s because there are two Plagiarism instances and RestTemplate does not know to which template to send the request. To fix this, we need to add an annotation @LoadBalanced to the RestTemplate in StudentConfig class to be able to load balance the requests:

```java
package com.anita.student;

import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class StudentConfig {

    @Bean
    @LoadBalanced
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

}
```

This time, after restarting the StudentApplication, when you send a request, it won’t get confused over sending requests to the instances:

<figure>
  <img src="https://i.imgur.com/1W4agrb.png" alt="Trulli" style="width:100%">
  <figcaption><center>Request successfully sent from Postman
</center></figcaption>
</figure>

You can also check the console logs. You will see that only one of the Plagiarism application logs will contain the information about the Student request.

<center>* * *</center>

We have successfully integrated a new module into our project, set up a service registry, and connected microservices via Service Discovery. If you have missed anything, all code can be found on my [GitHub repository](https://github.com/anitalakhadze/microservices_practice).

Please, let me know if you have any questions, comments, or suggestions for the upcoming blogs.

Stay tuned and don’t miss the following tutorials!