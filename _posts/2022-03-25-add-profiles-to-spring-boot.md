---
layout: post
title: Part 1 - HOW TO
subtitle: Add Profiles to a Spring Boot application
tags: [Profiles, Spring Boot, Configuration, Java]
comments: true
author: Ani Talakhadze
summary: This article explains how to use profiles in Spring Boot to manage environment-specific configurations. By creating profile-based property files and activating profiles as needed, you can easily switch between setups like development and production—making your application more flexible and maintainable.
---

Many of you, I’m sure, are interested in how to fine-tune your Spring Boot applications with little but meaningful things like adding profiles, customizing separate properties for different purposes, or creating mail configurations.

I’ve decided to start writing these mini-series to share my experiences with you. I hope that by the end of these tutorials, you will be happier with the quality of your code and will recommend additional topics to broaden our knowledge.

In this tutorial, I will show you how to add profiles to Spring Boot. They are a key aspect of the framework, allowing us to activate different profiles in various situations in order to bootstrap only the beans or properties we require.

## Profile-specific properties  

In this section, we will focus on creating profile-specific properties files. These have to be named in the format application-[profile].properties. Properties described in an application.properties file will be automatically loaded for all profiles and the ones in profile-specific .properties files will be loaded only for the specified profile.

The most common and basic example would be to configure different data sources for dev and production profiles by using two files named application-dev.properties and application-production.properties. Developers will find it easier to read, more practical to use, and less error-prone if configurations are split in this manner.

In the application-dev.properties file, we can set up a PostgreSQL data source:

```properties
# postgresql datasource
spring.datasource.url=jdbc:postgresql://localhost:[port]/distance
spring.datasource.username=postgres_example
spring.datasource.password=postgres_example
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.show-sql=true
spring.jpa.hibernate.ddl-auto=update
```

Then we can configure the same properties for the dev profile in the application-prod.properties file:

```properties
# oracle datasource
spring.datasource.url=jdbc:oracle:thin:@[address]:[port]/SERVICE
spring.datasource.username=oracle_example
spring.datasource.password=oracle_example
spring.datasource.driverClassName=oracle.jdbc.OracleDriver
spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.proc.param_null_passing=true
```

We can easily switch between profiles by simply defining the currently active profile in the application.properties:

```properties
spring.profiles.active=dev
```

If you prefer configuring data source in a separate component class instead of properties file, you can also make a bean belong to a particular profile by annotating it with the @Profile annotation which can take the names of one or multiple profiles. For example, if you have a bean that should only be active during development but not deployed in production, you can simply annotate the bean in the following way:

```java
@Component 
@Profile("dev") 
public class DevDatasourceConfig
```

<center>***</center>

In this brief tutorial, we discussed how to define separate profiles in Spring Boot using an example of data source configuration and then, how to enable the right profiles in our application.

In the next tutorial I will show you how to create separate property classes mapped to corresponding property files and use them inside the application using Dependency Injection.

Stay tuned and feel free to recommend in the comments section the topics you would like to be discussed in the following articles of these series!


