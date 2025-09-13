---
layout: post
title: Spring Boot Security - In-memory Authentication
tags: [Spring Boot, Sprint Security, In-memory Authentication, Java]
comments: true
author: Ani Talakhadze
summary: This post walks you through setting up in-memory authentication in Spring Boot Security. It explains how to configure user credentials and roles directly in your code, customize the authentication manager, and encode passwords—making it simple to test and secure your application without a database.
---

We spent quite a bit of time in the last blog describing basic concepts in Spring Boot Security, and if you haven’t read it yet, you can have a look at it here.

Now are going to take it a step further and set up authentication configuration in Spring Boot. Trust me, you will see how the knowledge from the previous blog will help us to navigate through code blocks.


## In-Memory Authentication  

Spring Boot produces user credentials for us once we add a Spring Security Starter Dependency to the classpath, as previously mentioned. We also had the option of defining the default user using the application.properties file, but this isn’t ideal in most cases. We’ll most likely want Spring Boot authentication to be based on a few existing users, either from a database or some external source. Within the scope of this blog, we will attempt to configure the application by hardcoding a few users and storing them in memory.


## AuthenticationManager and AuthenticationManagerBuilder  

The method we may set authentication in Spring Boot is by altering AuthenticationManager, which is a component in charge of authentication. It has a function authenticate() that either returns a successful authentication or throws an exception if the authentication fails. We may influence this component by customizing its logic using the AuthenticationManagerBuilder class and a builder pattern. However, we’ll have to find a way to get ahold of this class first and then configure it.

There is a method already present in the application named configure() that accepts AuthenticationManagerBuilder as an argument, and the Spring Boot framework calls that method and passes in the required input automatically. The purpose of this class’s accessibility is that developers may extend it and configure it in whatever manner they choose. This is exactly what we are going to do in the following steps.


## Configuring AuthenticationManager  

Firstly create a new project and add Spring Security and Spring Web dependencies from Sring Initializr. Then create a new package “security” and a class inside of that package — SecurityConfiguration. The important thing is for it to extend a special class called WebSecurityConfigurerAdapter. Then we have to override its method configure(). This class has many options for method configure(), however, we want the one which takes AuthenticationManagerBuilder as an argument.

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/1*vJOwHrfyApeWAqCquSG-Fw.png" alt="Trulli" style="width:100%">
  <figcaption><center>configure(AuthenticationManagerBuilder auth) method
</center></figcaption>
</figure>

First and foremost, we must choose the type of authentication we require, as this determines the settings. The AuthenticationManager will be affected once we have configured the AuthenticationManagerBuilder with the necessary parameters.

We’re setting up the authentication to be in-memory, so we’ll need to supply the user’s username, password, and role. We’ll use the method chaining pattern to avoid dealing with a large number of objects. The final step is to use the @EnableWebSecurity annotation to activate this setting and inform Spring Boot Security that it is a web security configuration. Other methods of security exist, but they are outside the scope of this article. We’re just dealing with web applications for now.

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/1*GrXXQYGvWk-ayghB80poKg.png" alt="Trulli" style="width:100%">
  <figcaption><center>Setting up in-memory authentication and enabling web security
</center></figcaption>
</figure>


## ... And Encoding Passwords  

There’s one more thing to do. When it comes to usernames and passwords, we don’t want them to be stored in plain text anywhere in our application. Passwords should be saved in an encoded manner. In this situation, too, Spring Security comes to our aid. It almost requires developers to encrypt passwords. All we have to do now is build a @Bean of type PasswordEncoder and expose it to Spring Security, which will search for any accessible beans and utilize our bean for password encoding once it finds it.

Spring Security supports a number of encoding mechanisms; however, for the sake of this tutorial, we will return a NoOpPasswordEncoder instance, which does nothing and works with plain text. Of course, this is for the sake of development. In general, the BCrypt password encoder is the best option since it employs more powerful algorithms than MD5 or Sha password encoders.

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/1*pclh9wrIbPW1YofI7Y8v5Q.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

After that, we may launch our program, visit the web page, and log in using our credentials in peace.

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/1*ZyfFonMPVKFC5D05XmV3Wg.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

We can use a very handy method named and() for adding as many users as we want.

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/1*QoclvVuyPxPbdCI8y5fbjA.png" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

<center>* * *</center>

Overall, we’ve obtained the AuthenticationManagerBuilder and set a few settings on it. We’ve informed it to utilize in-memory authentication, and we’ve given it a username, password, and role for a user. Instead of doing the default behavior, Spring Boot will now look at our class and derive our specific configuration.

In the next article, we will take a closer look at [database authentication](https://anitalakhadze.github.io/2021-12-03-spring-security-database-auth/) instead of retrieving users from memory so don’t miss it!