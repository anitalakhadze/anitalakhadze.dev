---
layout: post
title: Still Haven’t Tried Spring Cloud OpenFeign? You’re Missing Out
summary: If you’re tired of dealing with a lot of boilerplate code or just want a cleaner way to do things, Spring Cloud OpenFeign might be exactly what you need. In this article, we’ll talk about what OpenFeign is, why it’s worth using, and how you can get started with some practical examples.
---

<figure>
    <img src="https://i.imgur.com/tZO33tK.png" alt="Cleaner code with optional" style="width:100%">
</figure>

If you’ve ever tried to make an HTTP call in a Spring Boot project, you know it’s not as straightforward as it seems. Sure, you just need an HTTP client, but when you start looking at the options — RestClient, WebClient, RestTemplate… and all the manual configurations — it can quickly get overwhelming.

If you’re tired of dealing with a lot of boilerplate code or just want a cleaner way to do things, Spring Cloud OpenFeign might be exactly what you need. In this article, we’ll talk about what OpenFeign is, why it’s worth using, and how you can get started with some practical examples.

<div style="text-align: center;">* * *</div>

# The origins: from Feign to OpenFeign

I enjoy taking the time to understand things deeply because even small details matter. So, we’ll begin by exploring OpenFeign’s origins to better understand how and why it works. If you’re here for the hands-on part (which is totally fine), feel free to skip ahead to the Practical Guide section. Otherwise, grab a seat and let’s get started.

## What is Feign?
Feign is a declarative REST client library developed by Netflix as part of its open-source microservices ecosystem. The name Feign, meaning to pretend or simulate, reflects its purpose: you define Java interfaces with HTTP method annotations, and Feign generates the client implementations at runtime.

Here’s what a Feign client looks like:

```java
public interface BookClient {

    @RequestLine("GET /{isbn}")
    BookResource findByIsbn(@Param("isbn") String isbn);

    @RequestLine("GET")
    List<BookResource> findAll();

    @RequestLine("POST")
    @Headers("Content-Type: application/json")
    void create(Book book);

}
```

Feign uses the interface above as a blueprint to automatically create a working client without you writing HTTP-related code.

For example, `findByIsbn` fetches information about a specific book using its ISBN:

- `@RequestLine(“GET /{isbn}”)` means a `GET` request at a path like `/123456` where `123456` is an ISBN.
- `@Param(“isbn”)` maps the isbn parameter to `{isbn}` in the URL.
- `BookResource` is the object to which the response from the server will be converted to.
And so on, you get the idea…

Without using Feign (and using RestClient for example), your code may have looked like this instead:

```java
@Service
public class BookService {

    private final RestClient restClient;

    public BookService() {
        this.restClient = RestClient.builder()
            .baseUrl("http://book-api.com")
            .uriBuilderFactory(new DefaultUriBuilderFactory("http://book-api.com"))
            .build();
    }

    public BookResource findByIsbn(String isbn) {
        return restClient.get()
            .uri("/{isbn}", isbn)
            .retrieve()
            .body(BookResource.class);
    }

    public List<BookResource> findAll() {
        return restClient.get()
            .uri("/")
            .retrieve()
            .body(new ParameterizedTypeReference<List<BookResource>>() {});
    }

    public void create(Book book) {
        restClient.post()
            .uri("/")
            .contentType(MediaType.APPLICATION_JSON)
            .body(book)
            .retrieve()
            .toBodilessEntity();
    }
}
```

Feign, by reducing boilerplate code, allows us focus on application logic while the library “feigns” HTTP API clients using declarative interfaces.

## Transition to Spring Cloud OpenFeign

When Netflix introduced Feign, Spring Cloud integrated it as **Spring Cloud Netflix Feign**, making it easy to use in Spring Boot applications.

As Netflix evolved, they stopped maintaining several projects, including Feign. That’s when the community took over as **OpenFeign**, and Spring Cloud transitioned to **Spring Cloud OpenFeign** to align with the community-driven project.

> For a deeper understanding of how Feign evolved into OpenFeign, [introductory guide on Netflix Feign](https://www.baeldung.com/intro-to-feign) and this comparison article on [Netflix Feign vs. OpenFeign](https://www.baeldung.com/netflix-feign-vs-openfeign) are great resources.

# Practical Guide with OpenFeign

Spring Cloud OpenFeign builds on OpenFeign and integrates with the Spring ecosystem. It makes using Feign in Spring Boot applications easier with features like dependency injection, support for MVC annotations, load balancer integration, auto-configuration, better testing support, and custom configurations.

Let’s explore OpenFeign in practice and see how it can help write cleaner code in the right scenarios.

First, include the [OpenFeign dependency](https://mvnrepository.com/artifact/org.springframework.cloud/spring-cloud-starter-openfeign) in your `pom.xml`:

```xml
<dependency>  
    <groupId>org.springframework.cloud</groupId>  
    <artifactId>spring-cloud-starter-openfeign</artifactId>  
</dependency>
```

Add the `@EnableFeignClients` annotation to your main application class:

```java
@EnableFeignClients
@SpringBootApplication
public class SpringCloudOpenfeignDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringCloudOpenfeignDemoApplication.class, args);
    }

}
```

Add the information about the resource that you want to consume in your `application.yml` file. In this case, I will use [JSONPlaceholder](https://jsonplaceholder.typicode.com/) — a very nice free fake API ideal for such purposes:

```yml
spring:
  cloud:
    openfeign:
      client:
        config:
          post-service:
            url: https://jsonplaceholder.typicode.com/posts
```

Next, create a declarative interface and annotate with `@FeignClient(name = "post-service")`. Note, that the name defined in the configuration properties above should correspond to the name declared in the annotation.

```java
@FeignClient(name = "post-service")
public interface PostClient {

    @GetMapping
    List<Post> getPosts();

    @GetMapping("/{id}")
    Post getPostById(@PathVariable Long id);

    @GetMapping("/{id}/comments")
    List<Comment> getCommentsByPostId(@PathVariable Long id);

    @PostMapping
    Post createPost(@RequestBody Post post);

    @PutMapping("/{id}")
    Post updatePost(@PathVariable Long id, @RequestBody Post post);

    @DeleteMapping("/{id}")
    void deletePost(@PathVariable Long id);

}
```

Now inject the `PostClient` interface into your service class and call its methods:

```java
@Service
public class PostService {
    
    private final PostClient postClient;

    public PostService(PostClient postClient) {
        this.postClient = postClient;
    }

    public List<Post> getAllPosts() {
        return postClient.getPosts();
    }

    public Post getPostById(Long id) {
        return postClient.getPostById(id);
    }

    public List<Comment> getCommentsByPostId(Long postId) {
        return postClient.getCommentsByPostId(postId);
    }

    public Post createPost(Post post) {
        return postClient.createPost(post);
    }

    public Post updatePost(Long id, Post post) {
        return postClient.updatePost(id, post);
    }

    public void deletePost(Long id) {
        postClient.deletePost(id);
    }
    
}
```

And last, create a `PostController`:

```java
@RestController
@RequestMapping("/posts")
public class PostController {

    private final PostService postService;

    public PostController(PostService postService) {
        this.postService = postService;
    }

    @GetMapping
    public List<Post> getAllPosts() {
        return postService.getAllPosts();
    }

    @GetMapping("/{id}")
    public Post getPost(@PathVariable Long id) {
        return postService.getPostById(id);
    }

    @GetMapping("/{id}/comments")
    public List<Comment> getComments(@PathVariable Long id) {
        return postService.getCommentsByPostId(id);
    }

    @PostMapping
    public Post createPost(@RequestBody Post post) {
        return postService.createPost(post);
    }

    @PutMapping("/{id}")
    public Post updatePost(@PathVariable Long id, @RequestBody Post post) {
        return postService.updatePost(id, post);
    }

    @DeleteMapping("/{id}")
    public void deletePost(@PathVariable Long id) {
        postService.deletePost(id);
    }

}
```

**Let’s test the results:**

<figure>
    <img src="https://i.imgur.com/3KaEKRd.gif" alt="Testing controller methods one by one showcasing Feign client at work" style="width:100%">
    <figcaption style="text-align: center;">
        Testing controller methods one by one showcasing Feign client at work<br>
    </figcaption>
</figure>

Under the hood, what’s happening is that we’re making calls to our own controller endpoints at `localhost`. However, behind the scenes, our implementation is redirecting those calls to the **https://jsonplaceholder.typicode.com/posts** service, leveraging the Feign client to handle the communication.

# Advanced configuration

To make development even easier, OpenFeign supports advanced configurations.

🟢 **Need to intercept the request with authentication?** No problem. Implement `RequestInterceptor` from Feign:

```java
@Configuration
public class AuthInterceptorConfiguration implements RequestInterceptor {

    @Override
    public void apply(RequestTemplate requestTemplate) {
        String auth = "PUBLIC_KEY" + ":" + "SECRET_KEY";
        byte[] encodedAuth = Base64.getEncoder().encode(auth.getBytes(StandardCharsets.UTF_8));
        String authHeader = "Basic " + new String(encodedAuth);
        requestTemplate.header("Authorization", authHeader);
    }

}
```

And define it in the `application.yaml`:

```yml
spring:
  cloud:
    openfeign:
      client:
        config:
          post-service:
            url: https://jsonplaceholder.typicode.com/posts
            requestInterceptors:
              - com.anita.springcloudopenfeigndemo.AuthInterceptorConfiguration
```

🟢 **Need to customize logging levels?** Easy. Just add a desired logger-level property (supporting options — full, basic, headers and none) in application.yaml:

```yml
spring:
  cloud:
    openfeign:
      client:
        config:
          post-service:
            url: https://jsonplaceholder.typicode.com/posts
            logger-level: full
```

🟢 **Centralized error decoder?** Sure:

```java
@Component  
public class CustomErrorDecoder implements ErrorDecoder {  

    @Override  
    public Exception decode(String methodKey, Response response) {  
        // Custom error handling logic here  
        return new RuntimeException("Error occurred: " + response.status());  
    }  

}
```

🟢 **Fallback logic in case things go wrong?** Check. Add a dependency for [Circuitbreaker Resilience4j](https://mvnrepository.com/artifact/org.springframework.cloud/spring-cloud-starter-circuitbreaker-resilience4j) to your pom.xml:

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-circuitbreaker-resilience4j</artifactId>
    <version>3.2.0</version>
</dependency>
```

Add a fallback implementation of your Feign client:

```java
@Component
public class PostClientFallback implements PostClient {

    @Override
    public List<Post> getPosts() {
        return List.of();
    }

    @Override
    public Post getPostById(Long id) {
        return new Post(
                RandomGenerator.getDefault().nextLong(),
                RandomGenerator.getDefault().nextLong(),
                "fallback-title",
                "fallback-body"
        );
    }

    // The rest of the methods

}
```

And declare it in your Feign client definition like this:

```java
@FeignClient(name = "post-service", fallback = PostClientFallback.class)
public interface PostClient {

    // The rest of the methods

}
```

If something goes wrong with the service you’re consuming, the fallback implementation takes over. Simple and convenient.

<figure>
    <img src="https://i.imgur.com/tSQC6wu.gif" alt="Intentionally modifying service URL to cause a failure, demonstrating the use of fallback implementation in such cases" style="width:100%">
    <figcaption style="text-align: center;">
        Intentionally modifying service URL to cause a failure, demonstrating the use of fallback implementation in such cases<br>
    </figcaption>
</figure>

# When to use Spring Cloud OpenFeign?

To be able to answer when, it’s important to compare the capabilities of the available solutions.

🟡 Feign stands out with its simplicity and seamless integration with Spring, especially for declarative REST calls.

🟡 [WebClient](https://docs.spring.io/spring-framework/reference/web/webflux-webclient.html) is a powerful choice for reactive and asynchronous scenarios, ideal for handling streams of data.

🟡 [RestClient](https://docs.spring.io/spring-framework/reference/web/webflux-webclient.html) offers a modern and flexible approach for synchronous tasks, aligning with newer Spring features.

🟡 [RestTemplate](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/client/RestTemplate.html), though somewhat dated, remains reliable for straightforward, synchronous needs.

🟡 Additionally, you can consider [Apache’s HttpClient](https://www.geeksforgeeks.org/integrating-apache-httpclient-in-spring-boot/) or [OkHttp](https://www.baeldung.com/guide-to-okhttp) for advanced use cases requiring fine-grained control or performance optimization.

Each tool has its strengths, so the choice depends on your application’s architecture, complexity, and specific use case requirements.

<div style="text-align: center;">* * *</div>

The purpose of this blog was to share my appreciation for how Spring Cloud OpenFeign can serve as an elegant and powerful solution for making HTTP calls. It hasn’t been long since I discovered it, but it has quickly become one of my favorite tools for writing cleaner and more maintainable code.

If you’ve had a similar experience, or even a different perspective, I’d love to hear your thoughts in the comments!

That said, it’s important to remember that tools should fit the problem, not the other way around. Always evaluate your options carefully before deciding. If you’re intrigued by OpenFeign, I highly recommend checking out the [official documentation](https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html/). And if you’re curious about how it fits into the broader world of microservices, this [overview on GeeksforGeeks](https://www.geeksforgeeks.org/what-is-feign-client-in-microservices/) is also a great place to start.

All code samples shown in this tutorial are available over on GitHub.

And, as usual, stay tuned for the following blogs! ✨