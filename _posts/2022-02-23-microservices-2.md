---
layout: post
title: Microservices [Part 2]
subtitle: With Maven, Spring Boot and Docker
gh-repo: anitalakhadze/microservices_practice
gh-badge: [star, fork, follow]
tags: [Microservices, Spring Boot, Maven, Docker, PostgreSQL, Java]
comments: true
author: Ani Talakhadze
summary: This post continues the microservices series by adding a second service—Plagiarism—to the project, showing how to set up its own database, build REST endpoints, and enable communication between microservices using RestTemplate. It’s a practical guide to expanding your Spring Boot microservice architecture and connecting services together.
---

The series of lessons on constructing microservices using Maven, Spring Boot, and Docker is still ongoing. You can see a step-by-step tutorial on setting up a Maven project and creating a very simple microservice Student that is connected to a PostgreSQL database running in a Docker container in the first blog [here](https://anitalakhadze.github.io/2022-02-09-microservices-1/).

Let’s build a second microservice called Plagiarism in this part. It will have a communication with the Student microservice and verify if a student is plagiarizing or not.

The link to the source code repository will be added at the end of this tutorial.


## Plagiarism microservice  

Let’s start by creating a new module for Plagiarism which will be a Maven project:

<figure>
  <img src="https://i.imgur.com/BeNfQAU.png" alt="Trulli" style="width:100%">
  <figcaption><center>New module for the plagiarism microservice
</center></figcaption>
</figure>

For now, add Spring Boot Starter Web there inside the dependencies section of the pom.xml file:

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

You may have noticed that our new microservice has already been configured to refer to its parent — anitaservices:

<figure>
  <img src="https://i.imgur.com/Jn9Js5C.png" alt="Trulli" style="width:100%">
  <figcaption><center>Parent section inside the pom.xml of the Plagiarism microservice
</center></figcaption>
</figure>

We can also navigate to the parent’s pom.xml file and see that the new Plagiarism module has also been added there inside the modules section:

<figure>
  <img src="https://i.imgur.com/5LOwtiI.png" alt="Trulli" style="width:100%">
  <figcaption><center>Modules section inside the pom.xml of the parent project
</center></figcaption>
</figure>

Within src/main/java folder create a new package called com.anita.plagiarism and add the main class PlagiarismApplicationthere:

```java
package com.anita.plagiarism;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class PlagiarismApplication {

    public static void main(String[] args) {
        SpringApplication.run(PlagiarismApplication.class, args);
    }

}
```

Create an application.yml file for the plagiarism module inside the resources folder and paste the following information about the application name and server port (we are specifying a different port instead of the default one, as we don’t want both applications to start on the same port when we run them simultaneously):

```yaml
server:
  port: 8081

spring:
  application:
    name: plagiarism
```

You can also add a custom banner.txt file too if you wish.

<figure>
  <img src="https://i.imgur.com/wC9THdW.png" alt="Trulli" style="width:100%">
  <figcaption><center>Custom banner.txt file
</center></figcaption>
</figure>

After that, start both applications to make sure that everything is running smoothly. Also, don’t forget to start your Docker containers so that your Student microservice can connect to the database without any issues.

Next, let’s add a database for the Plagiarism microservice.


## Database setup  

In a typical microservice architecture, you will usually want to have one database per microservice. However, for the purposes of this tutorial, let’s just use the same database instance and add a database inside:

<figure>
  <img src="https://i.imgur.com/U042uG2.png" alt="Trulli" style="width:100%">
  <figcaption><center>Creating a new database — Plagiarism
</center></figcaption>
</figure>

Add the following data source configuration to the application.yml file:

```yaml
server:
  port: 8081

spring:
  application:
    name: plagiarism
  datasource:
    username: 'postgres'
    url: jdbc:postgresql://localhost:5432/plagiarism
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

Open the pom.xml file for the Plagiarism application and add spring boot data JPA and PostgreSQL dependencies.

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

Within our main package add a new Java class PlagiarismCheckHistory:

```java
package com.anita.plagiarism;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
public class PlagiarismCheckHistory {
    @Id
    @SequenceGenerator(
            name = "plagiarism_id_sequence",
            sequenceName = "plagiarism_id_sequence"
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "plagiarism_id_sequence"
    )
    private Long id;
    private Long studentId;
    private Boolean isPlagiarist;
    private LocalDateTime createdAt;
}
```

Restart the Plagiarism microservice and make sure that everything works. You can check the sequence and the table in pgadmin too on port 5050:

<figure>
  <img src="https://i.imgur.com/1yn6wKm.png" alt="Trulli" style="width:100%">
  <figcaption><center>Recently created sequence and a table inside the plagiarism database
</center></figcaption>
</figure>


## Controller, service, and repository  

Firstly, create aPlagiarismCheckHistoryRepository:

```java
package com.anita.plagiarism;

import org.springframework.data.jpa.repository.JpaRepository;

public interface PlagiarismCheckHistoryRepository extends JpaRepository<PlagiarismCheckHistory, Long> {
}
```

Then, create a PlagiarismCheckService which, at the moment, will always return false, but this will definitely change according to the real business logic:

```java
package com.anita.plagiarism;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@AllArgsConstructor
public class PlagiarismCheckService {
    private final PlagiarismCheckHistoryRepository plagiarismCheckHistoryRepository;
    
    public boolean isPlagiaristStudent(Long studentId) {
        plagiarismCheckHistoryRepository.save(
                PlagiarismCheckHistory.builder()
                        .studentId(studentId)
                        .isPlagiarist(false)
                        .createdAt(LocalDateTime.now()).build()
        );
        return false;
    }
}
```

Create a PlagiarismCheckResponse class. We will only include a boolean at the moment but you can add any information you want in the future:

```java
package com.anita.plagiarism;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PlagiarismCheckResponse {
    private Boolean isPlagiarist;
}
```

Finally, create a simple PlagiarismController with a method that will return information whether the student is a plagiarist or not:

```java
package com.anita.plagiarism;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("api/v1/plagiarism-check")
@AllArgsConstructor
@Slf4j
public class PlagiarismController {

    private final PlagiarismCheckService plagiarismCheckService;

    @GetMapping(path = "{studentId}")
    public PlagiarismCheckResponse isPlagiarist(@PathVariable("studentId") Long studentId) {
        boolean isPlagiaristStudent = plagiarismCheckService.isPlagiaristStudent(studentId);
        log.info("Plagiarism check request for student {}", studentId);
        return new PlagiarismCheckResponse(isPlagiaristStudent);
    }
    
}
```

Having finished configuring these parts, we can now move on to see how the communication between the microservices works.



## Communication via RestTemplate  

Communication between microservices can be achieved in a variety of ways. Let’s talk about the RestTemplate solution in this tutorial and leave the Service Discovery configuration for the next one.

A Student microservice is now running on port 8080, and a Plagiarism microservice is currently running on port 8081. We want the Student to submit a request to Plagiarism to determine whether a certain student who has been registered is a plagiarist or not.

Open the StudentService class and modify the todos we left in the previous part inside the register method:

```java
@Service
public record StudentService(StudentRepository studentRepository) {
    public void registerStudent(StudentRegistrationRequest request) {
        Student student = Student.builder()
                .firstName(request.firstName())
                .lastName(request.lastName())
                .email(request.email())
                .build();

        // TODO: Validate Request
        // TODO: Check if plagiarist
        studentRepository.save(student);
        // TODO: Send notification
    }
}
```

Then create a new StudentConfig class for returning a rest template:

```java
package com.anita.student;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class StudentConfig {

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

}
```

Inject this configuration inside our StudentService:

```java
package com.anita.student;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public record StudentService(StudentRepository studentRepository, RestTemplate restTemplate) {
    public void registerStudent(StudentRegistrationRequest request) {
        Student student = Student.builder()
                .firstName(request.firstName())
                .lastName(request.lastName())
                .email(request.email())
                .build();
        // TODO: Validate Request
        // TODO: Check if plagiarist
        studentRepository.save(student);
        // TODO: Send notification
    }
}
```

In this class I am using Java’s new feature — record, which is a way of declaring a type. If you are interested, you can read about this and all the other cool features that have been added to the most recent versions from Java 12 to Java 17 here in detail.

To see if a student is plagiarizing, we’ll need his or her ID, which will only be available once the student has been saved to the database. Thus, we will use saveAndFlush to catch the ID before the procedure ends:

```java
public void registerStudent(StudentRegistrationRequest request) {
    Student student = Student.builder()
            .firstName(request.firstName())
            .lastName(request.lastName())
            .email(request.email())
            .build();

    // TODO: Validate Request
    studentRepository.saveAndFlush(student);
    PlagiarismCheckResponse plagiarismCheckResponse = restTemplate.getForObject(
            "http://localhost:8081/api/v1/plagiarism-check/{studentId}",
            PlagiarismCheckResponse.class,
            student.getId()
    );
    if (plagiarismCheckResponse.isPlagiarist()) {
        throw new IllegalStateException("Student is a plagiarist!");
    }
    // TODO: send notification
}
```

## Testing the HTTP communication between microservices  

Time has come to test our application!

Restart both microservices, open the Postman and send a request to the student microservice. You will receive a 200 status code:

<figure>
  <img src="https://i.imgur.com/qQfHhZM.png" alt="Trulli" style="width:100%">
  <figcaption><center>Testing the changes from Postman
</center></figcaption>
</figure>

Open pgadmin and check the databases:

<figure>
  <img src="https://i.imgur.com/0xWgvLU.png" alt="Trulli" style="width:100%">
  <figcaption><center>Student database
</center></figcaption>
</figure>

<figure>
  <img src="https://i.imgur.com/V6c4nK7.png" alt="Trulli" style="width:100%">
  <figcaption><center>Plagiarism database
</center></figcaption>
</figure>

This is it! We have successfully modified the project, added a new microservice and implemented the necessary logic to establish communication between the applications.

<center>* * *</center>

If you have missed anything, all code can be found on my [GitHub repository](https://github.com/anitalakhadze/microservices_practice).

RestTemplate may be a fine solution for the purposes of this tutorial, however, it does not fit those situations when we have several instances of application running and a microservice has to know networking information about each of them, in order to be able to connect.

Instead of having to deal with ports, we are going to centralize the process with Eurika Server and make it responsible for load balancing the requests between microservices. So, stay tuned and don’t miss it out!

Also, comment below what would you like to see in the following blogs.

Happy coding!
