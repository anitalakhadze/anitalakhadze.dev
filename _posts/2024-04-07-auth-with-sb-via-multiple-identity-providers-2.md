---
layout: post
title: [Part 2] — Implementing Authentication with Spring Boot Security 6, OAuth2, and Angular 17 via Multiple Identity Providers
author: Ani Talakhadze
summary: Setting up the service and controller layers
---

<figure>
    <img src="https://i.imgur.com/GSfq3xf.png" alt="Spring Boot Security 6, OAuth 2 and Angular 17" style="width:100%">
</figure>

In the second part of this series, we focus on setting up the service and controller layer to handle the traditional email-password login flow. Additionally, we’ll cover fetching the logged-in user’s information, building upon the groundwork established in the first part. I encourage you to have a look at the introduction, if you have not read it yet.

Whether you’re catching up or following along, stay tuned for a step-by-step walkthrough to simplify your authentication process.

## Email-password login flow

Before we discuss the login service, let’s clarify how the login process works. According to the client’s instructions, here’s how it goes: an administrator from another app registers a user using their email. After that, the user can log in using social platforms or set a password on our app.

Users aren’t limited to one login method — they can use Google, GitHub, or a password, as long as their email is registered. If they set a password, they can switch to Google or any other provider(s) without any problem. Also, if they initially logged in with Google and later choose email and password, we automatically set the password for them during authentication.

So, basically the login service will only serve the traditional email-password flow and social provider logins will be handled by the OAuth2 that we configured in the previous tutorial. It’s a bit of a mix-up between login and signup processes, but hey, we’ve got to meet the client’s needs.

Let’s create our models first: `LoginRequest`

```java
package com.anita.multipleauthapi.model.payload;

import lombok.AllArgsConstructor;
import lombok.Data;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;

@Data
@AllArgsConstructor
public class LoginRequest {
    @NotBlank(message = "Email cannot be blank")
    @Email(message = "Email should be valid")
    private String email;

    @NotBlank(message = "Password cannot be blank")
    private String password;
}
```

and `LoginResponse`

```java
package com.anita.multipleauthapi.model.payload;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginResponse {
    private String accessToken;
}
```

Don’t forget to add the javax validation dependency too:

```xml
<dependency>
    <groupId>javax.validation</groupId>
    <artifactId>validation-api</artifactId>
    <version>2.0.1.Final</version>
</dependency>
```

Set up a simple service that will attempt to find the user by their email. If the password is empty, it will set the password and update the record. This way, authentication won’t fail. If a password is present, it will be checked by the authentication manager. Finally, we will update Spring Boot’s security context with the authenticated user’s information, or throw an exception if credentials were not verified.

```java
package com.anita.multipleauthapi.service;

import com.anita.multipleauthapi.model.entity.User;
import com.anita.multipleauthapi.model.error.BadRequestException;
import com.anita.multipleauthapi.model.payload.LoginResponse;
import com.anita.multipleauthapi.model.payload.LoginRequest;
import com.anita.multipleauthapi.repository.UserRepository;
import com.anita.multipleauthapi.security.TokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class LoginService {
    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenProvider tokenProvider;

    public LoginResponse login(LoginRequest loginRequest) {
        log.debug("Login request: {}", loginRequest);
        Authentication authentication;

        User user = userRepository
                .findByEmail(loginRequest.getEmail())
                .orElseThrow(() -> new BadRequestException("Email not registered by administrator yet."));

        if (StringUtils.isEmpty(user.getPassword())) {
            user.setPassword(passwordEncoder.encode(loginRequest.getPassword()));
            userRepository.saveAndFlush(user);
        }

        try {
            authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getEmail(),
                            loginRequest.getPassword()
                    )
            );
        } catch (AuthenticationException ex) {
            throw new BadRequestException("Bad credentials");
        }

        SecurityContextHolder.getContext().setAuthentication(authentication);

        String token = tokenProvider.createToken(authentication);
        return new LoginResponse(token);
    }
}
```

Finally, add the controller to expose the service to the web:

```java
package com.anita.multipleauthapi.controller;

import com.anita.multipleauthapi.model.payload.LoginRequest;
import com.anita.multipleauthapi.model.payload.LoginResponse;
import com.anita.multipleauthapi.service.LoginService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class LoginController {

    private final LoginService loginService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest loginRequest) {
        return ResponseEntity.ok(loginService.login(loginRequest));
    }

}
```

## Retrieving authenticated user’s information

Later when we set up the UI for our application, we will require to fetch some data about the user to show in the profile section once they are logged in.

For this purpose, create a `UserResponse`,

```java
package com.anita.multipleauthapi.model.payload;

import com.anita.multipleauthapi.model.enums.AuthProvider;
import lombok.Data;

@Data
public class UserResponse {
    private Long id;
    private String email;
    private String firstname;
    private String lastname;
    private AuthProvider authProvider;
    private String name;
    private String imageUrl;
}
```

a handy `ResourceNotFoundException`,

```java
package com.anita.multipleauthapi.model.error;

public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

and `UserService` that will simply fetch the information stored in the database:

```java
package com.anita.multipleauthapi.service;

import com.anita.multipleauthapi.model.entity.User;
import com.anita.multipleauthapi.model.payload.UserResponse;
import com.anita.multipleauthapi.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    public UserResponse getUserInfoById(Long id) {
        log.debug("Getting user info by id: {}", id);

        User user = userRepository
                .findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with ID: %s.".formatted(id)));

        return mapToUserResponse(user);
    }

    private static UserResponse mapToUserResponse(User user) {
        UserResponse userResponse = new UserResponse();
        userResponse.setId(user.getId());
        userResponse.setEmail(user.getEmail());
        userResponse.setFirstname(user.getFirstname());
        userResponse.setLastname(user.getLastname());
        return userResponse;
    }

}
```

Last, create a controller with one simple endpoint for getting the logged in user’s information:

```java
package com.anita.multipleauthapi.controller;

import com.anita.multipleauthapi.model.payload.UserResponse;
import com.anita.multipleauthapi.security.CurrentUser;
import com.anita.multipleauthapi.security.UserPrincipal;
import com.anita.multipleauthapi.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/user")
public class UserController {
    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(@CurrentUser UserPrincipal userPrincipal) {
        return ResponseEntity.ok(userService.getUserInfoById(userPrincipal.getId()));
    }

}
```

---

That’s it for this brief tutorial. In the following part, I plan to share the methods for obtaining credential information to configure the actual OAuth2 social login provider details in Spring Boot application properties.

As usual, the tutorial code can be found on [my GitHub repository](https://github.com/anitalakhadze/multiple-auth-api) under the branch tutorial/part-2 if you wish to explore it in isolation. Alternatively, you can track the application’s progress on the main branch.