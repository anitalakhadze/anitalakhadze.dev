---
layout: post
title: Ultimate Guide to Spring Boot Exception Handling
tags: [Spring Boot, Exception, Exception Handling, Java]
comments: true
author: Ani Talakhadze
summary: This guide explains how to handle exceptions gracefully in Spring Boot applications using @RestControllerAdvice. It covers creating custom error responses, managing specific exceptions, and centralizing error handling logic—helping you deliver clearer, more useful error messages to clients and maintain cleaner code.
---

Developers spend a lot of time ensuring the program’s usual, desired flow even when unexpected events occur. Programs may crash and requests may fail, exceptions like these should be handled gracefully. Handling each and every single exception with a separate try-catch block, however, is not maintainable. Luckily, both of these issues can be addressed with the help of powerful exception handling tools provided by Spring Boot.

Without any work on the developer’s part, the applications built with Spring Boot automatically use the default error handling mechanism. During the startup, if no mappings for the /error endpoint are found, Spring Boot uses a catch-all Whitelabel Error Page containing the HTTP status code and an error message. If instead, you make a bad RESTful request, Spring Boot will deliver a JSON representation of the same error that it displays on the “Whitelabel” error page shown below:

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/0*okP0JjfCNziRvHQv" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/0*i2yJmzAso0lru6-u" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

As you can see, these error messages are not helpful. This vagueness will soon become a problem, particularly for back-end developers of large applications where there are many possible sources of error. It’s also difficult for front-end developers, who might need specific API error response messages to effectively explain what happened to end-users. All these issues can be dealt with by a few lines of code via a popular custom error handling tool — @RestControllerAdvice.

@RestControllerAdvice is a relatively new annotation in Spring Framework that combines @ControllerAdvice and @ResponseBody. This extremely powerful mechanism enables us to manage a single, global error handling component, gives us full control over the body of the response and the status code, and allows the mapping of several exceptions to the same method.

So let’s get to coding! We will set a simple example for Spring Boot exception handling and explain the process step by step. For starters, we will create our own message response structure for describing API problems, including fields for storing the relevant information about errors encountered during REST calls.

```java
package com.example.demo.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@AllArgsConstructor
public class ErrorMessage {
    private int statusCode;
    private Date timestamp;
    private String message;
    private String description;
}
```

A common scenario for a Spring application that handles database calls is to have a method that can find a record by its ID using a repository class. In the case that the object is not present in the dataset, the method will return a null. To avoid a vague NullPointerException down the line, we are going to throw a custom exception in our Spring Boot controller. Let’s create a simple ResourceNotFoundException class.

```java
package com.example.demo.exception;

public class ResourceNotFoundException extends RuntimeException{
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

After we’ve constructed our custom exception, we can throw it from our controller to address the NullPointerException case and provide the client with all the relevant information to handle it properly.

```java
package com.example.demo.controller;

import com.example.demowithmysql.entity.User;
import com.example.demowithmysql.exception.ResourceNotFoundException;
import com.example.demowithmysql.repository.UserRepository;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping(path = "/demo")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/user/{id}")
    public User getUser(@PathVariable int id) {
        Optional<User> userOptional = userRepository.findById(id);
        if (!userOptional.isPresent()) {
            throw new ResourceNotFoundException(String.format("User with ID %s not found", id));
        }
        return userOptional.get();
    }
}
```

Now we are going to create a special class annotated by @RestControllerAdvice. This class will handle our custom ResourceNotFoundException and also, the following common global exceptions in just one place:

- ClassNotFoundException — an exception that occurs when an application tries to load a class through its fully qualified name and can not find its definition on the classpath — happens often if we forget to provide some dependency needed for running the application.
- InvocationTargetException — an exception which mainly occurs when we work with the reflection layer and try to invoke a method or constructor that throws an underlying exception itself.

```java
package com.example.demo.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.lang.reflect.InvocationTargetException;
import java.util.Date;

@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(value = ResourceNotFoundException.class)
    @ResponseStatus(value = HttpStatus.NOT_FOUND)
    public ErrorMessage resourceNotFoundException(ResourceNotFoundException ex) {
        return new ErrorMessage(HttpStatus.NOT_FOUND.value(),
                                new Date(),
                                ex.getMessage(),
                                "Resource Not Found");
    }

    @ExceptionHandler(value = ClassNotFoundException.class)
    @ResponseStatus(value = HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorMessage classNotFoundException(ClassNotFoundException ex) {
        return new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                                new Date(),
                                ex.getMessage(),
                                "Class Not Found On The Classpath");
    }

    @ExceptionHandler(value = InvocationTargetException.class)
    @ResponseStatus(value = HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorMessage invocationTargetException(InvocationTargetException ex) {
        return new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                                new Date(),
                                ex.getMessage(),
                                "Failed To Invoke Method or Constructor");
    }
}
```

As you can see, @RestControllerAdvice works by employing the @ExceptionHandler method-level annotation which specifies the type of Exception to be handled. Specifically, the exception thrown is compared to the exceptions passed as parameters, based on type. Only the first matching method is called. Then, the error is handled following the custom logic implementation.

Now, after we have gracefully handled each exception by returning our custom ErrorMessage, information about the exception is sufficient to deal with it on the client-side and display an appropriate message for the user. This ErrorMessage instance will be automatically serialized in JSON and used as the message body. This way, we have just created a custom error handling mechanism.

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/0*FlbzH3ujDB0u23Ov" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>

<figure>
  <img src="https://miro.medium.com/v2/resize:fit:720/format:webp/0*OmybgwGgZGPB7bHG" alt="Trulli" style="width:100%">
  <figcaption><center>
</center></figcaption>
</figure>