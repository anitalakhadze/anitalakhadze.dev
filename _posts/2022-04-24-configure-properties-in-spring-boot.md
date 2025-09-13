---
layout: post
title: Part 2 - HOW TO
subtitle: Configure properties in a Spring Boot application
tags: [Properties, Spring Boot, Configuration, Java]
comments: true
author: Ani Talakhadze
summary: This post explains a simple and effective way to organize and manage properties in Spring Boot projects. By grouping related settings into dedicated files and mapping them to configuration classes, it helps keep your codebase clean and maintainable—especially as your application grows.
---

I’m sure all of the developers like it when the code they are working with is neat and tidy. Writing clean code is a pleasurable activity that makes us all proud of our skills; however, viewing clean code is even much more satisfying.

A properties file in a Spring Boot project that contains all of the properties with various purposes in one location can become extremely difficult to manage as time passes and the code base grows.

In this tutorial, I’ll teach you one of the most basic methods for categorizing properties based on their meaning and purpose. This will make the development process as well as future feature enhancements much easier.


## Creating a Properties file  
Adding a new properties file to Spring Boot is just as simple as adding a new file in the resources folder on the classpath.

Let’s say you want to create a new file called mail.properties in project/src/main/resources/properties. Add the following configuration to the file (insert valid information instead of the bold phrases):

```properties
mail.host=mail.host.domain
mail.port=port
mail.transport.protocol=smtp
mail.properties.smtp-starttls-enable=true
mail.username=username@domain
mail.password=password
mail.properties.mail.smtp.auth=true
mail.sender.address=mail-sender-address@domain
```

In this file, we have outlined everything you may need to set up email service in the application. Keep in mind that we’ve been using the same keyword to define the attributes all along — “mail.” In a few moments, I will explain why.


## Registering Properties file in the Application  

Once you have your properties file ready, you can create a class representing those properties. Create a new Java class MailProperties in project-name/src/main or any of its subfolders, and place the following code inside:

```java
@Data
@Lazy
@Configuration
@PropertySource("classpath:/properties/mail.properties")
@ConfigurationProperties(prefix = "mail")
public class MailProperties {

    @Value("${mail.host}")
    private String host;

    @Value("${mail.port}")
    private Integer port;

    @Value("${mail.transport.protocol}")
    private String transportProtocol;

    @Value("${mail.properties.smtp-starttls-enable}")
    private String enableSmtpStartTls;

    @Value("${mail.username}")
    private String username;

    @Value("${mail.password}")
    private String password;

    @Value("${mail.properties.mail.smtp.auth}")
    private String smtpAuth;

    @Value("${mail.sender.address}")
    private String senderAddress;
}
```

To make our life easier, we’ve included a couple of annotations:

@Data is a convenient Lombok annotation that includes @Getter, @Setter, @ToString, @EqualsAndHashCode and @RequiredArgsConstructor annotations, and generates all the boilerplate code that is usually associated with POJOs. You may either add Lombok to your dependencies and utilize it, or you can include constructors and other structures.

As Spring Boot creates all beans eagerly at the start of the app context by default, @Lazy ensures that beans are created only when we request them. When the @Lazy annotation is applied to the @Configuration class, it means that all methods should be loaded lazily.

When combined with the @PropertySource annotation, the @Configuration annotation provides an easy way for adding property sources to the environment, processing the class, and creating suitable beans.

As you may remember, our properties were grouped together and started with “mail”. After we input the property prefix using @ConfigurationProperties(prefix = “mail”), Spring Boot applies its configuration technique and automatically maps between property names and their respective fields.

However, you might want to give your local fields a different name than the properties they correspond to. You can do this by annotating the field with @Value(“$mail.host”), which specifies the exact name of the property.


## Using Properties in the Application

When you’re done with this configuration class, you may inject it anywhere in your app and utilize it as needed:

```java
@Service
@Log4j2
@AllArgsConstructor
public class EmailService {
    private final MailProperties mailProperties;

    public void testProperties() {
        String host = mailProperties.getHost();
        String password = mailProperties.getPassword();
        String username = mailProperties.getUsername();
        // ... and so on
    }
}
```
<center>***</center>

In this short article, we explored how to configure properties in Spring Boot using the example of mail properties.

Of course, this isn’t the most comprehensive guide on specifying properties in a Spring Boot application; there are many more advanced options. This tutorial, however, should give you a solid notion of where to start, and it should suffice for small-scale applications.

In the next tutorial I will show you how to configure a mail sender service for a Spring Boot project.

Stay tuned and feel free to recommend in the comments section the topics you would like to be discussed in the following articles of these series!


