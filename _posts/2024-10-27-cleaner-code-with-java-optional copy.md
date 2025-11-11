---
layout: post
title: Cleaner Code with Java Optional - Examples, Best Practices and Exercises
summary: Refactoring Practical Java Cases for Better Code Flow
---

<figure>
    <img src="https://i.imgur.com/g0Tv910.png" alt="Cleaner code with optional" style="width:100%">
</figure>

- How many times have you encountered a NullPointerException from who-knows-where?
- How many times have you thought, “If only that developer had gracefully handled null values,” while debugging?
- How many times have you been lost while reading verbose null checks like (x == null && y != null && z == null…) cluttering the code?

What if I told you there’s a better way? Java’s Optional class not only cleans up code but enforces better practices, making value presence (or absence) explicit. This reduces runtime surprises, creates clearer APIs, and leads to more maintainable applications.

But why should you care? If you’re reading this, I believe you’re always looking to improve your style and write cleaner, more professional code.

However, spotting where Optional can improve your code isn’t always easy, especially for beginners. That’s why I’m sharing real-world examples where refactoring with Optional not only prevents null pointer errors but also improves readability, safety, and performance.

As always, you’ll find all the sample code in [my GitHub repo](https://github.com/anitalakhadze/refactor-using-optional). There’s a separate class for Exercises where you can practice refactoring using these concepts. If you get stuck, answers are on a separate branch.

<div style="text-align: center;">* * *</div>

# 🟢 Null Checks In Conditional Statements

```java
public int getDiscount(Customer customer) {
    if (customer != null && customer.discount() != null) {
        return customer.discount();
    }
    return 0;
}
```

> Here, our goal is to return customer’s discount, but we first check that both `customer` and `customer.discount()` are not `null`. If either check fails, we return a default value 0.

```java
public int getDiscountAfterRefactor(Customer customer) {
    return Optional.ofNullable(customer)
            .map(Customer::discount)
            .orElse(0);
}
```

> In this refactored version, using `Optional.ofNullable()` safely handles potential `null` values for `customer` or `customer.discount()`, while `Optional.orElse(0)` provides a default value if the discount is missing. This makes the code more concise and readable.

# 🟢 Returning Null From Methods

```java
public Address getAddress(User user) {
    if (user != null && user.address() != null) {
        return user.address();
    }
    return null;
}
```

> Like the previous example, we validate the object before returning `user.address()`. But returning null makes the client code responsible for handling `null` checks, increasing the risk of `NullPointerException`.

```java
public Optional<Address> getAddress(User user) {
    return Optional.ofNullable(user)
            .map(User::address);
}
```

> In this improved version, `Optional<Address>` as a return type of the method clearly signals that the value may be absent. This approach requires the caller to handle missing values explicitly, improving safety and clarity.

# 🟢 Chaining Method Calls

```java
public String getCountryName(User user) {
    if (user != null && user.address() != null && user.address().country() != null) {
        return user.address().country().name();
    }
    return "Unknown";
}
```

> Here, we rely on nested `null` checks just to access `country.name()`, making the code verbose and harder to follow. With deeply nested objects containing multiple nullable layers, this approach quickly becomes unmanageable.

```java
public String getCountryName(User user) {
    return Optional.ofNullable(user)
            .map(User::address)
            .map(Address::country)
            .map(Country::name)
            .orElse("Unknown");
}
```

> With `Optional`, we achieve clean and safe method chaining without the need for nested `if` statements. This makes the code more compact and readable.

# 🟢 Throwing Exceptions With Optional

```java
public User findUserById(Long id) {
    User user = userRepository.findById(id);
    if (user == null) {
        throw new RuntimeException("User not found for id: " + id);
    }
    return user;
}
```

> An `if` statement checks for a missing `user` and throws an exception when none is found.

```java
public User findUserById(Long id) {
    return Optional.ofNullable(userRepository.findById(id))
            .orElseThrow(() -> new RuntimeException("User not found for id: " + id));
}
```

> The refactored code with `Optional.orElseThrow()` simplifies this logic and clearly signals that an exception will be thrown if the `user` is missing, improving readability and conciseness.

# 🟢 Using Empty Optional For Clear Intent

```java
public Optional<Product> findProductByName(String name) {
    Product product = productRepository.findByName(name);
    if (product == null) {
        return null;
    }
    return Optional.of(product);
}
```

> When a method returns `Optional<T>`, the caller expects an `Optional`, not `null`. If `null` is returned, calling any `Optional` method leads to a `NullPointerException`, defeating the very reason `Optional` exists.

```java
public Optional<Product> findProductByName(String name) {
    return Optional.ofNullable(productRepository.findByName(name))
            .or(Optional::empty);
}
```

> Explicitly returning `Optional.empty()` when no product is found ensures the method never returns `null`, making the code more robust.

# 🟢 Conditional Logic With Optional.filter()

```java
public Optional<User> getActiveUser(User user) {
    if (user != null && user.isActive()) {
        return Optional.of(user);
    }
    return Optional.empty();
}
```

> In this example, we are using `null` checks combined with a boolean condition.

```java
public Optional<User> getActiveUser(User user) {
    return Optional.ofNullable(user)
            .filter(User::isActive);
}
```

> Refactoring with `Optional.filter()` allows us to clearly handle the case of an active user, making the intent explicit and reducing unnecessary conditional logic, resulting in cleaner, more functional code.

# 🟢 Performing Actions Conditionally

```java
public void notifyUser(User user) {
    if (user != null) {
        sendNotification(user);
    }
}
```

> In this example, we are checking the `user` to be present before proceeding with any action.

```java
public void notifyUser(User user) {
    Optional.ofNullable(user)
            .ifPresent(this::sendNotification);
}
```

> After refactoring, using `Optional.ifPresent()` clarifies that the action occurs only if the `user` is not `null`, resulting in simplified and expressive code.

```java
public void processLastOrder(Long orderId) {
    Optional<Order> orderOpt = orderRepository.findLatestByCustomerId(orderId);
    if (orderOpt.isPresent()) {
        handleOrder(orderOpt.get());
    } else {
        handleMissingOrder();
    }
}
```

> To bring the above example even further, here we are checking for the presence of `order`, performing different actions based on the result.

```java
public void processOrder(Long orderId) {
    orderRepository.findLatestByCustomerId(orderId)
            .ifPresentOrElse(this::handleOrder, this::handleMissingOrder);
}
```

> Using `ifPresentOrElse()` clearly separates actions for when the `Optional` is present and when it isn’t, simplifying the logic and removing manual checks.

# 🥁 Want to hear some of the best practices for using Optional?

`Optional` is many things, *but there are even more things that it is not*. Make sure to check out these practices not to misuse or overuse this helpful tool in your code.

## 🟡 Avoid using Optional in fields

Using `Optional` for fields complicates serialization and deserialization. For example, if a field is declared as `Optional<String>`, it may not be immediately obvious for someone reading the code that they need to handle both the `Optional` wrapper and the actual value inside it.

```java
public class User {
    private Optional<String> email;

    public User(Optional<String> email) {
        this.email = email;
    }

    public Optional<String> getEmail() {
        return email;
    }
}
```

`Optional` is meant to be used as a return type for methods to show that a value might be absent, not for fields in a class.

> Keep the class design simple.

```java
public class User {
    private String email;

    public User(String email) {
        this.email = email;
    }

    public String getEmail() {
        return email;
    }
}
```

## 🟡 Avoid using Optional in collections

Using `Optional` in collections, like `List<Optional<User>>`, adds unnecessary complexity. `Optional` is designed to represent a single value that may or may not be present, not to hold multiple values. Additionally, each `Optional` you create in a collection introduces a performance cost, which can add up in large lists.

```java
List<Optional<User>> users = ...;
List<User> validUsers = users.stream()
                          .filter(Optional::isPresent)
                          .map(Optional::get)
                          .collect(Collectors.toList());
```

Instead of using `Optional` for individual elements in a collection, it’s better to work directly with the collection of actual objects and filter out any `null` or absent ones during data collection.

> Keep the logic and the code simple and clean.

```java
List<User> validUsers = userIds.stream()
                          .map(userService::findById)
                          .filter(Objects::nonNull)
                          .collect(Collectors.toList());
```

# 🟡 Use orElse() and orElseGet() wisely

`orElse(T other)` method evaluates the provided fallback value regardless of whether the `Optional` contains a value. This can lead to unnecessary computations if the fallback value is expensive to create, especially if the `Optional` is often present.

```java
public class UserService {
    private String generateDefaultUsername() {
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        return "GuestUser";
    }
}
```

`orElseGet(Supplier<? extends T> other)` only runs the `Supplier` (which creates the fallback value) when the `Optional` is empty. This lazy evaluation improves performance, especially if generating the fallback value is resource-intensive.

> Use `orElseGet()` instead of `orElse()` when creating a default value is expensive.

```java
public String getUsername(String userId) {
    Optional<String> username = findUsername(userId);
    String defaultUsername = username.orElseGet(this::generateDefaultUsername);
    return defaultUsername;
}
```

## 🟡 Don’t overuse Optional

`Optional` is a great tool for signaling the potential absence of a value, but overusing it can lead to less readable code.

```java
public Optional<Integer> getProductCount() {
    return Optional.of(100);
}
```

If a method is expected to return a primitive or a straightforward value, using `Optional` may complicate things unnecessarily.

> Don’t clutter your code.

```java
public int getDefaultDiscount() {
    return 10;
}
```

<div style="text-align: center;">* * *</div>

Hopefully, you now see how using `Optional` in your daily workflows can help you **focus on writing cleaner, functional code**.

Due to the limited format, we have not discussed all the helpful tools in Optional class. Read about the rest of the methods [in the docs](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/Optional.html), like Optional.or() and Optional.orElseGet() and check out the exercises in my repo to give them a try.