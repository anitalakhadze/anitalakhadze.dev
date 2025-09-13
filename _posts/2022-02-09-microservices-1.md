---
layout: post
title: Microservices [Part 1]
subtitle: With Maven, Spring Boot and Docker
gh-repo: anitalakhadze/microservices_practice
gh-badge: [star, fork, follow]
tags: [Microservices, Spring Boot, Maven, Docker, PostgreSQL, Java]
comments: true
author: Ani Talakhadze
summary: This article introduces the basics of building microservices with Spring Boot, guiding you through setting up a Maven multi-module project, creating your first microservice, and connecting it to a PostgreSQL database running on Docker. With practical steps and clear examples, it’s a great starting point for anyone new to microservice architecture.
---

Microservices are so well-known in the IT industry right now that they don’t require a special introduction. If you’ve worked with monolithic programs before, you’ll understand how difficult it is to deploy them. From a range of viewpoints, the larger a software is, the more difficult it is to maintain it.

Microservices decouple components, allowing us to focus on a portion of the whole application, deploy faster, and improve faster. One of the finest features is the ability to use various databases and technologies.

In this article, I’ll teach you how to use Spring Boot to create a microservice that connects to a PostgreSQL database running on Docker. The link to the source code repository will be added at the end of this tutorial.

## Setting up Maven  

We will use Maven as our build tool for this project. You can skip this part if you have already installed Maven. If not, the installation guide for your operating system may be found here. However, if adding Maven to your path becomes a headache, there is another way around it if you are using IntelliJ IDEA as your current IDE.

You can find the path to Maven in the plugins folder in your IntelliJ directory under Program Files (if you’re using Windows like me). After that, go to System Properties and choose Environment Variables:

<figure>
  <img src="https://i.imgur.com/gHLsTWY.png" alt="Trulli" style="width:100%">
  <figcaption><center>System Properties Menu
</center></figcaption>
</figure>

Then, in system variables, add a new variable:

<figure>
  <img src="https://i.imgur.com/7PWKu5f.png" alt="Trulli" style="width:100%">
  <figcaption><center>Adding MAVEN_HOME to environment variables
</center></figcaption>
</figure>

Save the changes and use your command prompt to check your Maven version:

```shell
mvn -v
```

It will look something like this:

<figure>
  <img src="https://i.imgur.com/8FT4yFn.png" alt="Trulli" style="width:100%">
  <figcaption><center>Checking Maven version
</center></figcaption>
</figure>


## Setting up a new Spring Boot project  

Create a directory anyplace you like and run a shell from there. You can quickly open a terminal window in a folder by browsing to the folder from which you want to launch the command prompt window and entering cmd in the location bar at the top of the window. The command prompt will now open at the chosen place once you press enter. This has saved me a lot of time in the past.

Execute the following Maven goal on your command line to create a new Maven project (you may change the groupId, artifactId, and other parameters like that):

```shell
mvn archetype:generate -DgroupId=com.anita.practice -DartifactId=anitaservices -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false
```

The successful generation process will look like this:

<figure>
  <img src="https://i.imgur.com/ALbHRmM.png" alt="Trulli" style="width:100%">
  <figcaption><center>Successful generation of Maven project
</center></figcaption>
</figure>

The generate goal creates a new directory with the same name as the artifactId, as you can see. Change to that directory and use the command to take a look at the folder’s structure:

```shell
tree
```

It will be similar to this:

<figure>
  <img src="https://i.imgur.com/3KK78Co.png" alt="Trulli" style="width:100%">
  <figcaption><center>Parent project structure
</center></figcaption>
</figure>

This is a standard Maven project, as you can see. Let’s get started by opening the project in IntelliJ.


## Setting up parent module dependencies  

You are free to use any Java LTS version as long as it is compatible with our tutorial. I’m using Java 17 and the following is the structure of my project:

<figure>
  <img src="https://i.imgur.com/vihG4vM.png" alt="Trulli" style="width:100%">
  <figcaption><center>Project structure
</center></figcaption>
</figure>

The root folder is the parent project, in my case ‘anitaservices’. We’ll use Maven’s multi modules to have many different dependencies, and each submodule will be able to pick which dependencies to import and use. Within the parent module, we can also enforce dependencies on all microservices.

You may now remove the src folder from the parent project; we won’t need it for this lesson because this will only be a parent module.

Open the pom.xml file. Leave the properties and erase the dependencies’ content because we’ll be adding our own in a few minutes. Remove all plugins as well. After that, the file should be like follows:

```xml
<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.anita.practice</groupId>
  <artifactId>anitaservices</artifactId>
  <version>1.0-SNAPSHOT</version>

  <name>anitaservices</name>
  <url>https://www.example.com</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
  </properties>

  <dependencies>
  </dependencies>

  <build>
    <pluginManagement><!-- lock down plugins versions to avoid using Maven defaults (may be moved to parent pom) -->
      <plugins>
      </plugins>
    </pluginManagement>
  </build>
</project>
```

First, let’s add some new properties for plugins and dependency management:

```xml
<properties>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  <maven.compiler.source>17</maven.compiler.source>
  <maven.compiler.target>17</maven.compiler.target>
  <spring.boot.maven.plugin.version>2.5.7</spring.boot.maven.plugin.version>
  <spring.boot.dependencies.version>2.5.7</spring.boot.dependencies.version>
</properties>
```

If you like, you can control these versions individually.

Above the dependencies, add the dependencyManagement tag and the following dependency:

```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-dependencies</artifactId>
      <version>${spring.boot.dependencies.version}</version>
      <scope>import</scope>
      <type>pom</type>
    </dependency>
  </dependencies>
</dependencyManagement>
```

Here we will add dependencies that are optional for every module in the project.

We’ll now add some mandatory dependencies.

```xml
<dependencies>
  <dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
  </dependency>
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
  </dependency>
</dependencies>
```

After that, let’s add a plugin for building artifacts.

```xml
<build>
  <pluginManagement><!-- lock down plugins versions to avoid using Maven defaults (may be moved to parent pom) -->
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <version>${spring.boot.maven.plugin.version}</version>
      </plugin>
    </plugins>
  </pluginManagement>
</build>
```

Reload the file after modifications, and you’ll notice that all of the mandatory subproject dependencies have been added to the parent module dependencies:

<figure>
  <img src="https://i.imgur.com/orhdD6q.png" alt="Trulli" style="width:100%">
  <figcaption><center>Parent module dependencies
</center></figcaption>
</figure>

You can run clean and validate too to make sure that everything runs smoothly.


## Adding the first microservice  

Now that we’ve completed the fundamental architecture, we can start thinking about our first microservice, Student. We’ll also build a RESTful API that will allow us to post information about the student and a database.

Let’s start by creating a separate module in the parent folder:

<figure>
  <img src="https://i.imgur.com/ymD7aBG.png" alt="Trulli" style="width:100%">
  <figcaption><center>Creating a separate module for Student microservice
</center></figcaption>
</figure>

By naming the module on the following page, you’re essentially naming the microservice. The groupId for this module is the same as the parent’s, but the artifactId is different, as you can see in the Artifact Coordinates:

<figure>
  <img src="https://i.imgur.com/ZN66oND.png" alt="Trulli" style="width:100%">
  <figcaption><center>Artifact coordinates of the Student microservice
</center></figcaption>
</figure>

After you click Finish, a new folder will appear in your project. You’ll also see the newly added modules section if you open the parent pom.xml file:

<figure>
  <img src="https://i.imgur.com/Zd5GFhj.png" alt="Trulli" style="width:100%">
  <figcaption><center>Modules section in the parent module’s pom.xml file
</center></figcaption>
</figure>

When you open the student folder, you’ll notice that it’s structured precisely like a standard Maven project. There is also a parent section in the student’s pom.xml file:

<figure>
  <img src="https://i.imgur.com/NCCg2yr.png" alt="Trulli" style="width:100%">
  <figcaption><center>Parent section in the module’s pom.xml file
</center></figcaption>
</figure>

In this module, we’ll need a RESTful web service. We’ll add a web dependency by adding the following lines to the pom.xml file:

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

If you click this little symbol next to the dependencies section

<figure>
  <img src="https://i.imgur.com/9t7ald9.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

it will navigate you to spring boot dependencies of version 2.5.7

<figure>
  <img src="https://i.imgur.com/8Tr7ZVv.png" alt="Trulli" style="width:100%">
  <figcaption><center>Spring Boot dependencies according to the version specified in the parent’s pom.xml file
</center></figcaption>
</figure>

This web dependency is derived from the spring boot dependencies mentioned in the parent pom.xml file, as you may have anticipated. From here, each microservice may select the dependencies it requires.

Create a new package inside the java folder of the project and create a StudentApplication class there:

<figure>
  <img src="https://i.imgur.com/UDVyjFc.png" alt="Trulli" style="width:100%">
  <figcaption><center>StudentApplication main class
</center></figcaption>
</figure>

We are going to annotate this class by @SpringBootApplication and insert the main method responsible for running the application. After this basic setup, the class should look like this:

```java
package com.anita.student;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class StudentApplication {

    public static void main(String[] args) {
        SpringApplication.run(StudentApplication.class, args);
    }
    
}
```

Let’s also create an application.yml file in the resources folder of the module and declare basic properties:

```yaml
server:
  port: 8080
  
spring:
  application:
    name: student
```

Now if you check your Maven section in the IDE, you will see that it contains actions for our new module too:

<figure>
  <img src="https://i.imgur.com/WFCcdBm.png" alt="Trulli" style="width:100%">
  <figcaption><center>Maven section contains student module with its own dependencies
</center></figcaption>
</figure>

Web dependency is only included in the student module, as intended and test and Lombok dependencies are mandatory for modules as specified in the pom.xml of the parent module.

You can also create a custom banner for your module, which is pretty crazy, right? Go to [this website](https://devops.datenkollektiv.de/banner.txt/index.html) and copy the banner from there:

<figure>
  <img src="https://i.imgur.com/hUnCkYr.png" alt="Trulli" style="width:100%">
  <figcaption><center>Creating a custom banner for a Spring Boot application
</center></figcaption>
</figure>

Go back, create a banner.txt file in the resources folder and paste that in. Spring Boot will automatically pick that up for you.

<figure>
  <img src="https://i.imgur.com/ci3M1J9.png" alt="Trulli" style="width:100%">
  <figcaption><center>Adding banner.txt to the resources folder
</center></figcaption>
</figure>

Now if you run the StudentApplication, you will see that the app will start with the specified custom banner:

<figure>
  <img src="https://i.imgur.com/2PsXmS1.png" alt="Trulli" style="width:100%">
  <figcaption><center>Application has successfully started with the custom banner
</center></figcaption>
</figure>


## Creating model, controller, service  

Bootstrapping the project with Spring Boot was quite easy as you see. Now, within our main working folder, let’s create a simple Student model for our microservice:

```java
package com.anita.student;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class Student {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
}
```

Next, let’s create a StudentRegistrationRequest model for representing a student registration request. For this, I used Java’s new record feature. Record is a fantastic feature since it eliminates the boilerplate code that comes with POJOs, but if you’re using older versions of Java, you can just use an ordinary class.

```java
package com.anita.student;

public record StudentRegistrationRequest(
        String firstName,
        String lastName,
        String email) {
}
```

Let’s create a StudentService that will handle these requests:

```java
package com.anita.student;

import org.springframework.stereotype.Service;

@Service
public record StudentService() {
    public void registerStudent(StudentRegistrationRequest request) {
        Student student = Student.builder()
                .firstName(request.firstName())
                .lastName(request.lastName())
                .email(request.email())
                .build();

        // TODO: Validate Request
        // TODO: Store Student in DB
    }
}
```

For the moment I have inserted some TODOs in the code but we will get back to it in a second.

We also need to define a REST StudentController for our service:

```java
package com.anita.student;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("api/v1/students")
public record StudentController(StudentService studentService) {

    @PostMapping
    public void registerStudent(@RequestBody StudentRegistrationRequest studentRegistrationRequest) {
        log.info("New Student Registration {}", studentRegistrationRequest);
        studentService.registerStudent(studentRegistrationRequest);
    }
}
```

The application is gradually taking shape, as you can see. Now is the time to set up our database and configure our application so that we can store our students in it.


## PostgreSQL and pgAdmin on Docker

Create a new file named docker-compose.yml in the parent folder anitaservices and put the following settings inside:

```yaml
services:
  postgres:
    container_name: postgres
    image: postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      PGDATA: /data/postgres
    volumes:
      - postgres:/data/postgres
    ports:
      - "5432:5432"
    networks:
      - postgres
    restart: unless-stopped
  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL:-pgadmin4@pgadmin.org}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD:-admin}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    volumes:
      - pgadmin:/var/lib/pgadmin
    ports:
      - "5050:80"
    networks:
      - postgres
    restart: unless-stopped

networks:
  postgres:
    driver: bridge

volumes:
  postgres:
  pgadmin:
```

We won’t go into great detail, but keep in mind that we’re declaring two services, networks, and volumes here. For database and GUI, we’ll use Postgres and pgAdmin, respectively. In the setup, we’re exposing ports and defining a shared network between them.

If you have an ultimate edition of IntelliJ IDEA, you can run it directly from the file, but I’ll teach you how to do it from the terminal. Open a shell in the directory where the docker-compose.yml file is located and run the following command to start docker processes:

```shell
docker compose up -d
```

The processes will run in a detached thread. You can check the status by calling

```shell
docker compose ps
```

and you will see that we have two containers running — Postgres on port 5432 and pgAdmin on port 5050 talking to each other through the shared network.

<figure>
  <img src="https://i.imgur.com/5ei8QWk.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

You can navigate to the URL HTTP://localhost:5050 in the browser and if you see something like this, congratulations, you have successfully started the docker processes:

<figure>
  <img src="https://i.imgur.com/7D4LAIs.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>


## Creating a new server in pgAdmin  

Let’s create a new server. As we’re connecting from one container to another, the host is Postgres. The network has been defined in the config file. Give a name to this server and fill in the connection properties with your credentials like this:

<figure>
  <img src="https://i.imgur.com/T17Az8r.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

While adding a new server, if you’re having strange issues like me, when the host refuses to connect or you can’t log in to the Postgres container because the Postgres role doesn’t exist, let me help you and spare you a day of research and debugging.

One of the problems may be that Postgres is running on the same port locally, so the container has trouble running. If you don’t require PostgreSQL, you may remove it locally, or merely stop the service from the Windows services menu (if you are using Windows).

The second problem may be the error message “database authentication failed” while providing correct credentials. Even if you try to log in to the container with the user postgres, it may tell you that the role postgres is not found. These commands can save your day and allow you to finally create a new server:

```shell
docker-compose down --volumes
docker-compose down --rmi all --volumes
docker-compose up -d --force-recreate
```

Hopefully, you already have a database that we can work with and now, we can configure our microservice to connect to it.


## Configuring the application to connect to the database  

Copy the following code and paste it below the application name in your application.yml file:

```yaml
datasource:
  username: 'postgres'
  url: jdbc:postgresql://localhost:5432/student
  password: 'postgres'
jpa:
  properties:
    hibernate:
      dialect: org.hibernate.dialect.PostgreSQLDialect
      format_sql: 'true'
  hibernate:
    ddl-auto: update
  show-sql: 'true'
```

The data source key, username, URL, and password are all present. Since our application does not start as a container, the URL is localhost. We’d have to connect over the network if it was a container.

As our database’s name is student, let’s make a database with that name:

<figure>
  <img src="https://i.imgur.com/ueNhc2V.png" alt="Trulli" style="width:100%">
  <figcaption><center>Database "student" has been created
</center></figcaption>
</figure>

The final step is to open the student’s pom.xml file and add the JPA and PostgreSQL dependencies.

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

To properly represent Student as a database object, open your Student class and make the following changes:


```java
package com.anita.student;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@Data
@Builder
@Entity
@AllArgsConstructor
@NoArgsConstructor
public class Student {
    @Id
    @SequenceGenerator(
            name = "student_id_sequence",
            sequenceName = "student_id_sequence"
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "student_id_sequence"
    )
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
}
```

Create a simple JPA StudentRepository for students:

```java
package com.anita.student;

import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentRepository extends JpaRepository<Student, Long> {
}
```

Inject this repository into the StudentService and save the student in the database.

```java
package com.anita.student;

import org.springframework.stereotype.Service;

@Service
public record StudentService(StudentRepository studentRepository) {
    public void registerStudent(StudentRegistrationRequest request) {
        Student student = Student.builder()
                .firstName(request.firstName())
                .lastName(request.lastName())
                .email(request.email())
                .build();

        // TODO: Validate Request
        
        studentRepository.save(student);
    }
}
```


## Testing the application  

Restart the application to apply changes. If you check pgAdmin, you will see the newly added table and sequence:

<figure>
  <img src="https://i.imgur.com/MWpWRBd.png" alt="Trulli" style="width:100%">
  <figcaption><center>Table and sequence have been added to the database
</center></figcaption>
</figure>

The table, however, is currently empty. You can use Postman to submit a POST request to our API and check if we can save a Student:

<figure>
  <img src="https://i.imgur.com/8cLcrFQ.png" alt="Trulli" style="width:100%">
  <figcaption><center>Postman POST request to the API
</center></figcaption>
</figure>

Let’s run a query against our table to see what we get:

<figure>
  <img src="https://i.imgur.com/cIYSapH.png" alt="Trulli" style="width:100%">
  <figcaption><center>Querying the table to see if the student has been added
</center></figcaption>
</figure>

You can see that our microservice is connected to its own database. Mission accomplished!

<center>***</center>

I know this tutorial was a bit lengthy, but I hope you enjoyed learning these things. If you have missed anything, all code can be found on [my GitHub repository](https://github.com/anitalakhadze/microservices_practice).

Let’s look at how we may use our project with Spring Cloud and Kubernetes in the following tutorial.

Stay tuned and don’t miss it out!