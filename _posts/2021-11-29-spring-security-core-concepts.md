---
layout: post
title: Spring Boot Security - Core Concepts Explained
tags: [Spring Boot, Sprint Security, Java, Authentication, Authorization]
comments: true
author: Ani Talakhadze
summary: This article breaks down the core concepts of Spring Boot Security, explaining authentication, authorization, principals, roles, and authorities in clear terms. It introduces the Spring Security starter dependency and how it automatically adds login functionality, preparing you to understand and implement secure authentication and authorization in your Java applications.
---

Dealing with security risks becomes crucial for the application’s long-term sustainability and development for every Java developer out there at some time. While Java is not a very easy language to learn, Spring Boot may be claimed to make it a lot easier. In this circumstance, Spring Security simplifies our job and provides alternatives for setting our application.


## Terms and Concepts  

You may hunt for very specific answers, test them out, and then stop looking into the intricacies behind the solutions if they work. However, I highly suggest you to become acquainted with all of Spring Security’s essential concepts. After that, you’ll be able to see every step clearly, and navigating all of this security mess will no longer be a waste of time.

Authentication — Who are you? Can you prove it?

Authentication is the process of ascertaining whether or not someone or something is who or what they claim to be. There are several methods of authentication based on the credentials a user must supply when attempting to log in to an application. The first form is knowledge-based authentication (KBA), which is based on the individual’s knowledge. We may place username-password authentication in this category. Following that is possession-based authentication (PBA), which is based on something the user possesses. In this case, phone/text messaging, key cards and badges, and so on can be utilized. The third type of authentication is multi-factor authentication (MFA), which is a mixture of the first two and requires the user to give two or more verification factors in order to obtain access to the application.

Authorization — Can you do this?

Many people mistakenly use the phrases authentication and authorization interchangeably, although they are not the same thing. Simply defined, authorization is the process of determining which precise rights/privileges/resources a person has, whereas authentication is the act of determining who someone is. As a result, authorization is the act of granting someone permission to do or have something. Furthermore, authorization is frequently viewed as both the preparatory setting up of permissions and the actual checking of permission values when a user is granted access.

Principal

A principal is a person who is authenticated through the authentication procedure. Consider it a presently logged-in user of the currently logged-in account. One person can have many IDs (for example, Google), but there is generally only one logged in user. You may get it from the security context, which is connected to the current thread and hence to the current request and its session. As a result, the Spring Security principle can only be accessed as an Object and must be cast to the appropriate UserDetails instance, as I will describe in more detail in the future blogs.

Granted Authority

These are the user’s fine-grained permissions that define what the user may perform. Each conferred power can be thought of as an individual privilege. READ_AUTHORITY and WRITE_AUTHORITY are two examples. The name is arbitrary in this context, and we may alternatively refer to the idea of authority by using privilege.

Role

This is a coarser-grained set of authorities granted to the user (for example, ROLE_TEACHER, ROLE_STUDENT…). A role is expressed as a String that begins with “ROLE.” The semantics we attach to how we utilize the feature is the primary distinction between granted authority and role.


## Spring Boot Starter Dependency  

Spring Boot includes a spring-boot-starter-security package that collects all Spring Security dependencies in one place. Adding this dependency to the classpath causes the login form to be created automatically. The username is “user” by default, and the password is logged in the app, as seen in the image.

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/1*kbcWtAU6Qt3RnxL7QJ8K9w.png" alt="Trulli" style="width:100%">
  <figcaption><center>Spring Security Form Login
</center></figcaption>
</figure>

The password is automatically refreshed each time the program is relaunched, however we may change this setting and specify the desired username and password in the application.properties file. This might be beneficial for debugging. The password will no longer be logged in the software after that. We’ll get the Spring Boot default Whitelabel Error Page after successfully logging in.

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/1*wTjoeijirz6awP7T9mksSA.png" alt="Trulli" style="width:100%">
  <figcaption><center>Overriding default settings from application.properties
</center></figcaption>
</figure>

All of this is handled by the filters that sit behind the servlets that serve as the framework’s foundation. A filter is a fundamental notion in Spring Boot Security since it intercepts each request before it reaches the servlets. We may create filters in any combination, and they will prevent the request from progressing to the next filter unless all of the requirements are fulfilled.

Familiarizing ourselves with these notions will tremendously assist us in navigating the authentication and authorization setup that I will discuss in the next blogs.