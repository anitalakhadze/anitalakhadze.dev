---
layout: post
title: Spring Security With JWT
tags: [Spring Boot, Sprint Security, JWT, Authentication, Authorization, Java]
comments: true
author: Ani Talakhadze
summary: This comprehensive tutorial explains how to secure your Spring Boot applications using JWT (JSON Web Tokens) and Spring Security. It covers JWT concepts, project setup, user and role management, authentication and authorization logic, token generation and validation, and practical code examples—equipping you to implement secure, stateless authentication for your web applications.
---

In this tutorial, you’ll learn all you need to know about using Spring Boot with JWT to protect your applications. Everything in this section may be used in your Angular, React, or other apps.

If you’ve read any of my articles, you’re probably aware that I try to highlight the concepts behind the solutions, so, before we dive into the code, let’s clarify what JWT is. This understanding, in my opinion, will substantially assist you in implementing these security aspects with more awareness and presence. Let us not spend any more of our valuable time and get down to business!


## What is JWT?  

JWT stands for JSON Web Token (JWT) and is a method of exchanging data across apps. Its appeal stems from the fact that it is compact, self-contained, and extremely safe. It’s really simple to use since you may send it in the request body, headers, or forms.

The most typical situation is to use JWTs for authorization. When a user logs in, your backend application generates a JWT token containing the user’s information and digitally signs it. The token will be sent as proof of authorization whenever a user wishes to access routes, services, or resources after that.


## What is the structure of JWT?  

To clarify, JWT is made up of three parts: header, payload, and signature, which are separated by dots. Each component of the JWT is encoded in Base64Url. They are simple to pass in an HTTP environment, and they are also more compact than their alternatives.

The header typically contains information about the type of token and the signature algorithm used, such as SHA256 or RSA.

The payload includes relevant and interoperable information on the claims, such as iss (issuer), exp (expiration time), sub (subject), and so on. You should not put any sensitive information in the payload or header components of a JWT unless it is encrypted, as this information is viewable by anybody, even if it is secured against modification.

We need to use the encoded header, encoded payload, a secret, and the algorithm specified in the header to create the final, signature section. The signature verifies that the message has not been tampered with along the route.

For future reference, on the internet, there is a great [website](https://jwt.io/) that allows you to put these principles into practice by enabling you to decode, validate, and generate JWTs.


## Setting up the project  

We’ll create an example application to demonstrate how to use JWT for authorization in this tutorial. Let’s start by making a project with the following dependencies: Spring Web, Spring Data JPA, MySQL Driver, Spring Security, and Lombok.

We will configure our database connection in the application.properties file:

```properties
spring.jpa.hibernate.ddl-auto=update
spring.datasource.url=jdbc:mysql://${MYSQL_HOST:localhost}:3306/jwt_demo
spring.datasource.username=jwtdemouser
spring.datasource.password=password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
```

Our application will have a class User that may look something like this - a simple class with desired properties that will be mapped to a database table:

```java
package com.example.springbootsecuritydemo.user;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.Collection;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String name;
    private String username;
    private String password;
    @ManyToMany(fetch = FetchType.EAGER)
    private Collection<Role> roles = new ArrayList<>();
}
```

We’ll also need a class Role to represent user roles, which will also be mapped to a database table:

```java
package com.example.springbootsecuritydemo.user;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String name;
}
```

After that, we can create a UserRepository that extends JpaRepository and acts as an abstraction for storing and managing our data. In the case of a user, it will contain a custom method for getting a user by the unique username and will look like this:

```java
package com.example.springbootsecuritydemo.user;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    User findByUsername(String username);
}
```

And in case of a role, RoleRepository will be similar to this:

```java
package com.example.springbootsecuritydemo.user;

import org.springframework.data.jpa.repository.JpaRepository;

public interface RoleRepository extends JpaRepository<Role, Long> {
    Role findByName(String username);
}
```

Then, let’s move on and create a UserService interface with all of the methods we’ll need to display and modify our user data:

```java
package com.example.springbootsecuritydemo.user;

import java.util.List;

public interface UserService {
    User saveUser(User user);
    Role saveRole(Role role);
    void addRoleToUser(String username, String roleName);
    User getUser(String username);
    List<User> getUsers();
}
```

The UserServiceImpl will implement the above-mentioned UserService and execute database operations with the help of UserRepository and RoleRepository instances. For the sake of this tutorial, we’ll keep the implementation really simple:

```java
package com.example.springbootsecuritydemo.user;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    @Override
    public User saveUser(User user) {
        return userRepository.save(user);
    }

    @Override
    public Role saveRole(Role role) {
        return roleRepository.save(role);
    }

    @Override
    public void addRoleToUser(String username, String roleName) {
        User user = userRepository.findByUsername(username);
        Role role = roleRepository.findByName(roleName);
        user.getRoles().add(role);
        userRepository.save(user);
    }

    @Override
    public User getUser(String username) {
        return userRepository.findByUsername(username);
    }

    @Override
    public List<User> getUsers() {
        return userRepository.findAll();
    }
}
```

After we have implemented the service, let’s set up UserController with relevant API endpoints:

```java
package com.example.springbootsecuritydemo.user;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api")
public class UserController {
    private final UserService userService;

    @GetMapping("/users")
    public ResponseEntity<List<User>> getUsers() {
        return ResponseEntity.ok().body(userService.getUsers());
    }

    @PostMapping("/user/save")
    public ResponseEntity<User> saveUser(@RequestBody User user) {
        URI uri = URI.create(ServletUriComponentsBuilder.fromCurrentContextPath().path("/api/user/save").toUriString());
        return ResponseEntity.created(uri).body(userService.saveUser(user));
    }

    @PostMapping("/role/save")
    public ResponseEntity<Role> saveRole(@RequestBody Role role) {
        URI uri = URI.create(ServletUriComponentsBuilder.fromCurrentContextPath().path("/api/role/save").toUriString());
        return ResponseEntity.created(uri).body(userService.saveRole(role));
    }

    @PostMapping("/role/addtouser")
    public ResponseEntity<?> addRoleToUser(@RequestBody RoleToUserForm form) {
        userService.addRoleToUser(form.getUsername(), form.getRoleName());
        return ResponseEntity.ok().build();
    }
}

@Data
class RoleToUserForm {
    private String username;
    private String roleName;
}
```

As the final step in this section, let’s add this CommandLineRunner bean to our main class and load some roles and users into the database to test our application and actually see some data (don’t forget to delete this bean after first start of the application as you will get exceptions for trying to insert duplicate values afterwards):

```java
@Bean
CommandLineRunner run(UserService userService) {
    return args -> {
        userService.saveRole(new Role(null, "ROLE_USER"));
        userService.saveRole(new Role(null, "ROLE_MANAGER"));
        userService.saveRole(new Role(null, "ROLE_ADMIN"));
        userService.saveRole(new Role(null, "ROLE_SUPER_ADMIN"));

        userService.saveUser(new User(null, "user1", "user1", "123", new ArrayList<>()));
        userService.saveUser(new User(null, "user2", "user2", "123", new ArrayList<>()));
        userService.saveUser(new User(null, "user3", "user3", "123", new ArrayList<>()));
        userService.saveUser(new User(null, "user4", "user4", "123", new ArrayList<>()));

        userService.addRoleToUser("user1", "ROLE_USER");
        userService.addRoleToUser("user2", "ROLE_MANAGER");
        userService.addRoleToUser("user3", "ROLE_ADMIN");
        userService.addRoleToUser("user4", "ROLE_ADMIN");
        userService.addRoleToUser("user4", "ROLE_USER");
        userService.addRoleToUser("user4", "ROLE_SUPER_ADMIN");
    };
}
```

Spring Security is now providing user credentials for us without any additional setup. Fortunately, configuring in-memory authentication - hardcoding a few users, and storing them in memory is simple and straightforward. I won’t go into great depth about this process; however, you can read a step-by-step guide in my previous blog. Our SecurityConfiguration class should look something like this after we define some users:

```java
package com.example.springbootsecuritydemo.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.inMemoryAuthentication()
                .withUser("user")
                .password("password")
                .roles("ADMIN")
                .and()
                .withUser("admin")
                .password("password")
                .roles("USER");
    }
    
    @Bean
    PasswordEncoder passwordEncoder() {
        return NoOpPasswordEncoder.getInstance();
    }
}
```

Once we start the application and log in to it, we can actually see some data coming from the database:

<figure>
  <img src="https://i.imgur.com/JkUhfKS.png" alt="Trulli" style="width:100%">
  <figcaption><center>Fetching list of users after login
</center></figcaption>
</figure>


## Authentication and authorization configuration  

Let’s change our authentication setup to database authentication at this point to come closer to production settings. The loadUserByUsername() method from the UserDetailsService interface can be used for this in our UserServiceImpl class:

```java
@Service
@Transactional
@RequiredArgsConstructor
public class UserServiceImpl implements UserService, UserDetailsService {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username);
        if (user == null) {
            throw new UsernameNotFoundException("User not found in the database");
        }
        Collection<SimpleGrantedAuthority> authorities = new ArrayList<>();
        user.getRoles()
                .forEach(role -> authorities
                        .add(new SimpleGrantedAuthority(role.getName())));
        return new org.springframework.security.core.userdetails.User(
                user.getUsername(), user.getPassword(), authorities);
    }

    // ...
}
```

Then, in SecurityConfiguration class, we have to add a PasswordEncoder type bean and modify the configure(AuthenticationManagerBuilder auth) and configure(HttpSecurity http) methods:

```
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {
    private final UserDetailsService userDetailsService;
    private final BCryptPasswordEncoder bCryptPasswordEncoder;

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

My previous blogs cover all you need to know about Spring Security authentication and authorization, so we won’t get into more details now.


## Generating JWT  

We need to be able to generate a token, sign it, and send it to the user in some way. That’s a lot of work to do by ourselves, so let’s make use of a great external library. Add the following to the dependencies list in your pom.xml and refresh the file:

```xml
<dependency>
    <groupId>com.auth0</groupId>
    <artifactId>java-jwt</artifactId>
    <version>3.18.2</version>
</dependency>
```

Now create a new class CustomAuthenticationFilter which will extend UsernamePasswordAuthenticationFilter abstract class and override methods attemptAuthentication() and successfulAuthentication(). We can also override unsuccessfulAuthentication() method if we want to do something if the login did not succeed.

attemptAuthentication() is the method called when someone tries to log in to the application. Here, we need to get hold of the username and password parameters from the request to build a UsernamePasswordAuthenticationToken object and pass it to AuthenticationManager instance for the actual authentication:

```java
@Slf4j
public class CustomAuthenticationFilter extends UsernamePasswordAuthenticationFilter {
    private final AuthenticationManager authenticationManager;

    public CustomAuthenticationFilter(AuthenticationManager authenticationManager) {
        this.authenticationManager = authenticationManager;
    }

    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response) throws AuthenticationException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        log.info("Username: {}, password: {}", username, password);
        UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(username, password);
        return authenticationManager.authenticate(authToken);
    }

    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain, Authentication authResult) throws IOException, ServletException {
        // ...
    }
}
```

successfulAuthentication(), as the name suggests, is called when a user has successfully logged in. Here, we need to access the user that has been authenticated — called the principal. Then we will define an algorithm with the desired cryptography. The secret key that is passed to the algorithm as an argument would normally be encrypted somewhere secure, but for this tutorial, we will leave it as a plain text.

After that, we’ll be able to make a token. We’ll need to pass in a subject, which can be whatever string you want as long as it’s something unique about the user so you can identify them by that token — for example, username or Id since they’re unique to us. Then we can choose an expiration date — in our example, 10 minutes, as well as an issuer — which will be our application’s URL, and claims — which will include all of the user’s roles. Finally, we have to sign the token with the algorithm and send it to the user using response headers.

```java
@Override
protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain, Authentication authResult) throws IOException, ServletException {
    User principal = (User) authResult.getPrincipal();
    Algorithm algorithm = Algorithm.HMAC256("secretKey".getBytes());
    String accessToken = JWT.create()
            .withSubject(principal.getUsername())
            .withExpiresAt(new Date(System.currentTimeMillis() + 10 * 60 * 1000))
            .withIssuer(request.getRequestURL().toString())
            .withClaim("roles", principal
                    .getAuthorities()
                    .stream()
                    .map(GrantedAuthority::getAuthority)
                    .collect(Collectors.toList()))
            .sign(algorithm);
    response.setHeader("access_token", accessToken);
}
```

Now that we have completed the generation of JWT, we have couple of little steps left before we can test login. Firstly, we must use our PasswordEncoder to encode the passwords of new users before storing them to the database. So, add these few lines to our UserServiceImpl class:

```java
@Service
@Transactional
@RequiredArgsConstructor
public class UserServiceImpl implements UserService, UserDetailsService {
// ...
    @Override
    public User saveUser(User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }
// ...
}
```

Then, we should inject our CustomAuthenticationFilter into authorization configuration. The final result will look like the following:

```
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

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        CustomAuthenticationFilter customAuthenticationFilter = new CustomAuthenticationFilter(authenticationManagerBean());
        http
                .csrf().disable()
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                .and().authorizeRequests().anyRequest().permitAll()
                .and().addFilter(customAuthenticationFilter);
    }

    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }
}
```


## Testing the application  

My API client of choice is Postman, but you may use anything you like. We must enter our credentials as x-www-form-urlencoded values in the body and then browse to http://localhost:8080/login using a POST request. The access token value will be received in headers as intended.

<figure>
  <img src="https://i.imgur.com/0luPwL3.png" alt="Trulli" style="width:100%">
  <figcaption><center>Testing the login with Postman
</center></figcaption>
</figure>

We can go to [jwt.io](https://jwt.io/) and double-check the value to ensure that the received token has all of the information we require:

<figure>
  <img src="https://i.imgur.com/nuhekuV.png" alt="Trulli" style="width:100%">
  <figcaption><center>Checking the token information on jwt.io
</center></figcaption>
</figure>

We can make our life easier by returning the access token value directly in the body of the response instead of using response headers. Simply modify the successfulAuthentication() method as follows:

```java
@Override
protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain, Authentication authResult) throws IOException {
    User principal = (User) authResult.getPrincipal();
    Algorithm algorithm = Algorithm.HMAC256("secretKey".getBytes());
    String accessToken = JWT.create()
            .withSubject(principal.getUsername())
            .withExpiresAt(new Date(System.currentTimeMillis() + 10 * 60 * 1000))
            .withIssuer(request.getRequestURL().toString())
            .withClaim("roles", principal
                    .getAuthorities()
                    .stream()
                    .map(GrantedAuthority::getAuthority)
                    .collect(Collectors.toList()))
            .sign(algorithm);
    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    new ObjectMapper().writeValue(response.getOutputStream(), accessToken);
}
```

After restarting the application and testing again, we now receive the JWT right in the response body:

<figure>
  <img src="https://i.imgur.com/SPPFleJ.png" alt="Trulli" style="width:100%">
  <figcaption><center>Testing the login with Postman
</center></figcaption>
</figure>


## Completing the authorization configuration  

Now let’s see whether we can really use our access token to access the server’s resources. At this point, it’s almost as if we don’t have any security at all, because we’re allowing any request without authorization. Modify the configure(HttpSecurity http) method to allow unauthorized requests only to the “/login” endpoint and to approve requests to all other endpoints as follows:

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    CustomAuthenticationFilter customAuthenticationFilter = new CustomAuthenticationFilter(authenticationManagerBean());
    http
            .csrf().disable()
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and().authorizeRequests().antMatchers("/login").permitAll()
            .and().authorizeRequests().antMatchers(HttpMethod.GET, "/api/user/**").hasAnyAuthority("ROLE_USER")
            .and().authorizeRequests().antMatchers(HttpMethod.POST, "/api/user/save/**").hasAnyAuthority("ROLE_ADMIN")
            .and().authorizeRequests().anyRequest().authenticated()
            .and().addFilter(customAuthenticationFilter);
}
```

After testing the application again, you will see that everything works as expected.


## Validating the JWT  

When a user signs in to the program, we can already give them an access token. Now we need to be able to accept this token from the user and then grant them access to the resources once we’ve confirmed that it’s valid. To do so, we’ll need to create an authorization filter. This filter will intercept all requests coming into the application, search for that specific token, process it, and then determine whether or not the user has access to specified resources.

Let’s make a new class that implements OncePerRequestFilter named CustomAuthorizationFilter. To filter each request that comes into the application, we’ll need to implement a method called doFilterInternal(). We don’t want the “/login” path to be authorized, therefore that’s the first thing we should check. If that’s the case, we know the user is simply attempting to log in, therefore we don’t need to do anything but transmit the request and answer to the next filter in the chain. If anything goes wrong throughout the process, we’ll need to catch exceptions.

```java
@Override
protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
    if (request.getServletPath().equals("/login")) {
        filterChain.doFilter(request, response);
    } else {
        String authorizationHeader = request.getHeader(AUTHORIZATION);
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            try {
                String token = authorizationHeader.substring("Bearer ".length());
                Algorithm algorithm = Algorithm.HMAC256("secretKey".getBytes());
                JWTVerifier verifier = JWT.require(algorithm).build();
                DecodedJWT decodedJWT = verifier.verify(token);
                String username = decodedJWT.getSubject();
                String[] roles = decodedJWT.getClaim("roles").asArray(String.class);
                Collection<SimpleGrantedAuthority> authorities = new ArrayList<>();
                Arrays.stream(roles).forEach(role ->
                        authorities.add(new SimpleGrantedAuthority(role)));
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(username, null, authorities);
                SecurityContextHolder.getContext().setAuthentication(authToken);
                filterChain.doFilter(request, response);
            } catch (Exception ex) {
                log.error("Error loggin in: {}", ex.getMessage());
                response.setStatus(FORBIDDEN.value());
                String errorMessage = ex.getMessage();
                response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                new ObjectMapper().writeValue(response.getOutputStream(), errorMessage);
            }
        } else {
            filterChain.doFilter(request, response);
        }
    }
}
```

We can now add this filter to our authorization configuration, but we must ensure that it comes before any other filters since we want to intercept all requests before they reach any other filters.

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    CustomAuthenticationFilter customAuthenticationFilter = new CustomAuthenticationFilter(authenticationManagerBean());
    http
            .csrf().disable()
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and().authorizeRequests().antMatchers("/login").permitAll()
            .and().authorizeRequests().antMatchers(HttpMethod.GET, "/api/user/**").hasAnyAuthority("ROLE_USER")
            .and().authorizeRequests().antMatchers(HttpMethod.POST, "/api/user/save/**").hasAnyAuthority("ROLE_ADMIN")
            .and().authorizeRequests().anyRequest().authenticated()
            .and().addFilter(customAuthenticationFilter)
            .addFilterBefore(new CustomAuthorizationFilter(), UsernamePasswordAuthenticationFilter.class);
}
```

The authentication and authorization filters are now available. Let’s test the outcomes by refreshing the application. If we try to access any resource without providing any authorization information, we will receive the following error response:

<figure>
  <img src="https://i.imgur.com/155bLWi.png" alt="Trulli" style="width:100%">
  <figcaption><center>Error response when no authorization header sent
</center></figcaption>
</figure>

Even if we try to submit an authorization header with a random string attached to “Bearer ”, the library will respond with an error message:

<figure>
  <img src="https://i.imgur.com/45vz9Ry.png" alt="Trulli" style="width:100%">
  <figcaption><center>Error message when an incorrect authorization header is sent
</center></figcaption>
</figure>

If we submit the request with a valid JWT value in the authorization header, we will get the following response as expected:

<figure>
  <img src="https://i.imgur.com/Y5c8jSd.png" alt="Trulli" style="width:100%">
  <figcaption><center>Response when a valid authorization header is sent
</center></figcaption>
</figure>

<center>* * *</center>

We learned how to protect a backend application using JWT, Spring Boot, and Spring Security in this tutorial. We used a JWT access token to get access to resources from secured endpoints. From now on, you can already create a way for two applications to connect and communicate with each other on your own.

There are more interesting and exciting topics to come, so stay tuned!