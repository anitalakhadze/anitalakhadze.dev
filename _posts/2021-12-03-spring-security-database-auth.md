---
layout: post
title: Spring Security - Database Authentication
tags: [Spring Boot, Sprint Security, Database Configuration, Java]
comments: true
author: Ani Talakhadze
summary: This post explains how to set up database-backed authentication in Spring Boot Security using MySQL and JPA. It guides you through configuring user entities, repositories, and services, then shows how to connect everything with a secure authentication setup—making it easy to manage users and roles from your database instead of in-memory storage.
---

We saw an example of an in-memory authentication configuration in Spring Boot in the last article. However, in-memory authentication will not be an ideal solution as our program expands and develops additional features, especially in production settings. You’ll almost certainly wish to verify your users using the data in your database. That’s exactly what we’ll be doing right now.


## Setting up the project  

Let’s start by creating a new project that includes Spring Web, Spring Security, MySQL Driver, Spring Data JPA, and Lombok dependencies. After that, your pom.xml file’s dependencies section should look like this:

```xml
...
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.data</groupId>
        <artifactId>spring-data-jpa</artifactId>
        <version>2.6.0</version>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <scope>runtime</scope>
    </dependency>
</dependencies>
...
```


## MySQL Database Connection Configuration  

Next, we’ll use the following script to set up a new database and database user for this tutorial:

```bash
\sql
\connect root@localhost //your credentials go here
create database registration_demo
create user 'registrationdemouser'@'%' identified by 'password';
grant all on registration_demo.* to 'registrationdemouser'@'%';
```

The application’s database connection properties will be defined after that in the application.properties file:

```properties
spring.jpa.hibernate.ddl-auto=update
spring.datasource.url=jdbc:mysql://${MYSQL_HOST:localhost}:3306/registration_demo
spring.datasource.username=registrationdemouser
spring.datasource.password=password
spring.datasource.driver-class-name =com.mysql.cj.jdbc.Driver
#spring.jpa.show-sql: true
```


## Implementing UserDetails Interface  

After we’ve completed the preceding steps, we may move on to the app user. Create a new package in the project called “appuser” to hold the user-related classes, such as a new class AppUser and an enum AppUserRole (with values USER and ADMIN). The AppUser class should implement the UserDetails interface from Spring security. You are free to add as many attributes as you wish. Remember to set the Id generation strategy for our AppUser class because it is an Entity. Once we’ve completed implementing the UserDetails interface, our class should look like this:

```java
package com.example.springbootsecuritydemo.appuser;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import javax.persistence.*;
import java.util.Collection;
import java.util.Collections;

@Getter
@Setter
@EqualsAndHashCode
@NoArgsConstructor
@Entity
public class AppUser implements UserDetails {
    @Id
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "user_sequence"
    )
    @SequenceGenerator(
            name = "user_sequence",
            sequenceName = "user_sequence",
            allocationSize = 1
    )
    private Long id;
    private String name;
    private String username;
    private String email;
    private String password;
    @Enumerated(EnumType.STRING)
    private AppUserRole appUserRole;
    private Boolean locked;
    private Boolean enabled;

    public AppUser(String name,
                   String username,
                   String email,
                   String password,
                   AppUserRole appUserRole,
                   Boolean locked,
                   Boolean enabled) {
        this.name = name;
        this.username = username;
        this.email = email;
        this.password = password;
        this.appUserRole = appUserRole;
        this.locked = locked;
        this.enabled = enabled;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority(appUserRole.name());
        return Collections.singleton(authority);
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return !locked;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }
}
```


## Creating a service  

To begin, consider how we may perform a query on our database to get users by their usernames. We can solve this by creating a repository with a custom method that returns an Optional of an AppUser based on their unique email address:

```java
package com.example.springbootsecuritydemo.appuser;

import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
@Repository
@Transactional(readOnly = true)
public interface AppUserRepository {
    Optional<AppUser> findByEmail(String email);
}
```

Next, we are going to create a service class that implements Spring Security’s UserDetailsService interface. It will provide a method loadUserByUsername(String s), which is how we will authenticate our users when they try to log in to our app. This repository we prepared earlier will be used in our AppUserService class to load users by usernames or throw an error if no matching user is found:

```java
package com.example.springbootsecuritydemo.appuser;

import lombok.AllArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class AppUserService implements UserDetailsService {
    
    private final static String USER_NOT_FOUND_MSG = "User with email %s not found";
    private final AppUserRepository appUserRepository;
    
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return appUserRepository
                .findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException(String.format(USER_NOT_FOUND_MSG, username)));
    }
}
```


## Security Configuration  

We must configure Spring Security to use our database authentication mechanism after it has been correctly set up. In our project, we’ll construct a new class to contain security-related settings. My previous posts provide further details concerning key principles and handling web security.

Our security configuration class should extend WebSecurityConfigurerAdapter class and override method configure(AuthenticationManagerBuilder auth). Using a builder pattern, we will set the userDetailsService and passwordEncoder properties on the auth object. As you know, we have already implemented UserDetailsService interface in our AppUserService above. As for the password encoder, we will tell Spring Security to use BCryptPasswordEncoder. Finally, the class should look something like this:

```java
package com.example.springbootsecuritydemo.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {
    private final UserDetailsService userDetailsService;
    private final PasswordEncoder bCryptPasswordEncoder;

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth
                .userDetailsService(userDetailsService)
                .passwordEncoder(bCryptPasswordEncoder);
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

<center>* * *</center>

We’ve created a new database, a service to load users from it, and set up spring security to utilize our service for authentication when users attempt to log in to our app. In the next article, we’ll try to improve our tools and look into configuring authorization, so stay tuned!