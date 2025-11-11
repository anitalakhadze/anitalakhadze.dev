---
layout: post
title: Essential Stream Operations in Java
author: Ani Talakhadze
summary: Boost Your Java Efficiency With Examples, Exercises And Fun Facts
---

![captionless image](https://miro.medium.com/v2/resize:fit:1210/format:webp/1*QXK9vB03OsZKF-jB8-uUyg.png)

We all agree that building a strong foundation is crucial for becoming a proficient developer. With that in mind, streams are undeniably among the handiest tools in our arsenal for solving various problems.

That’s why I’m here to share the top 10 stream operations I use every day. I’ll break down each operation with clear explanations and examples, including more advanced demonstrations combining multiple operations.

Head over to [**my GitHub repo**](https://github.com/anitalakhadze/essential-stream-operations) where you will see the code from the tutorial, as well as exercises at all levels: beginner, intermediate, and advanced _(don’t forget to add_ `**-ea**` _to VM options, so assertion errors can be thrown and you can track your progress appropriately)_. Give it a star, try out the exercises in your free time, and watch your skills grow. Stuck? No worries! I’ve got an `**answers**` branch with all the solutions ready to go.

Hit that follow button for more content like this, and share your ideas for future topics.

### **Explanations and Examples**

  **map** — arguably one of the most popular operations _(and my personal favorite)_ is used to apply a function to each element in the stream, producing a new stream of the transformed elements.

> **_Example_**: we transform each pet name to uppercase using the `**map**` operation and collect the resulting uppercase names into a new list using the `**toList**` collector.

```
public static void main(String[] args) {
    List<String> pets = List.of("Hamster", "Cat", "Dog");
    List<String> upperCaseNames = pets
            .stream()
            .map(String::toUpperCase)
            .toList();
    assert List.of("HAMSTER", "CAT", "DOG").equals(upperCaseNames);
}
```

**filter** is used to selectively include elements in the stream based on a specified condition.

> **Example**: Using the `**filter**` operation, we selectively retain only the even numbers by applying a lambda expression that checks if each number is divisible by 2 without a remainder. Subsequently, the `**toList**` collector collects these even numbers into a new list.

```
public static void main(String[] args) {
    List<Integer> numbers = List.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
    List<Integer> evenNumbers = numbers
            .stream()
            .filter(number -> number % 2 == 0)
            .toList();
    assert List.of(2, 4, 6, 8, 10).equals(evenNumbers);
}
```

**collect** accumulates elements from the stream into a collection, such as a List, Set, or Map (_we have already used one of such collectors —_ `**toList**` _above_).

> **Example**: By using the `**collect**` method with the `**Collectors.toSet**` collector, we transform the stream of fruits into a set, ensuring uniqueness of elements.

```
public static void main(String[] args) {
    List<String> fruits = List.of("apple", "peach", "banana", "cherry", "banana", "peach");
    Set<String> fruitSet = fruits
            .stream()
            .collect(Collectors.toSet());
    assert fruitSet.size() == 4;
}
```

**flatMap** is used to merge a stream of streams into a single stream, thus effectively flattening nested structures.

> **Example**: we start with a list of lists, where each inner list represents a category of shapes. By using the `**flatMap**` operation, we transform the stream of lists into a single stream of shapes, effectively flattening the nested structure. The resulting collection contains all the shapes from the original nested lists.

```
public static void main(String[] args) {
    List<List<String>> shapes = List.of(
            List.of("triangle", "rectangle", "square"), // sharp forms
            List.of("circle", "ellipse", "cylinder") // rounded forms
    );
    List<String> flattenedShapes = shapes
            .stream()
            .flatMap(Collection::stream)
            .toList();
    assert flattenedShapes.size() == 6;
    assert List.of("triangle", "rectangle", "square", "circle", "ellipse", "cylinder").equals(flattenedShapes);
}
```

**reduce** combines elements of the stream into a single result with an accumulation function, thus simplifying complex computations.

> **Example**: we apply the `**reduce**` operation to calculate the sum of all numbers in the list. The initial value of the accumulator is set to 0, and we use the `**Integer::sum**` method reference as the binary operator to perform the summation. The result, stored in the `**sum**` variable, represents the total sum of the numbers in the list.

```
public static void main(String[] args) {
    List<Integer> numbers = List.of(1, 2, 3, 4, 5);
    Integer sum = numbers
            .stream()
            .reduce(0, Integer::sum);
    assert sum == 15;
}
```

**forEach** allows us to loop through each element in the stream, enabling us to perform an action.

> **Example**: `**forEach**` method iterate sover each element in the numbers list. Within the lambda expression, each number is multiplied by 2, resulting in the doubled value being printed to the console.

```
public static void main(String[] args) {
    List<Integer> numbers = List.of(1, 2, 3, 4, 5);
    numbers.forEach(num -> System.out.println(num * 2));
}
```

**distinct** removes duplicate elements from the stream, ensuring uniqueness in the output.

> **Example**: By chaining the `**distinct**` operation, we filter out duplicate elements, ensuring that each unique number appears only once in the resulting stream. The distinct numbers are then collected into a new list using the `**toList**` collector.

```
public static void main(String[] args) {
    List<Integer> numbers = List.of(1, 2, 3, 4, 4, 4, 5);
    List<Integer> distinctNumbers = numbers
            .stream()
            .distinct()
            .toList();
    assert List.of(1, 2, 3, 4, 5).equals(distinctNumbers);
}
```

**sorted** is used to sort elements in the stream according to their natural order or a custom comparator that we provide.

> **Example**: with the `**sorted**` operation, we arrange the numbers in ascending order. The sorted numbers are then collected into a new list using the `**toList**` collector.

```
public static void main(String[] args) {
    List<Integer> numbers = List.of(3, 1, 6, 8, 2, 4, 5, 9, 7);
    List<Integer> sorted = numbers
            .stream()
            .sorted()
            .toList();
    assert List.of(1, 2, 3, 4, 5, 6, 7, 8, 9).equals(sorted);
}
```

**skip** enables us to skip a designated number of elements from the start of the stream, while `**limit**` enables us to specify the maximum number of elements we wish to process from the beginning.

> **Example**: using the `**skip**` operation, we bypass the first 2 elements of the stream, resulting in a new stream containing elements starting from the third element onwards. Similarly, we use the `**limit**` operation to restrict the stream to only the first 3 elements.

```
public static void main(String[] args) {
    List<Integer> numbers = List.of(1, 2, 3, 4, 5);
    List<Integer> skipped = numbers
            .stream()
            .skip(2)
            .toList();
    assert List.of(3, 4, 5).equals(skipped);
    List<Integer> limited = numbers
            .stream()
            .limit(3)
            .toList();
    assert List.of(1, 2, 3).equals(limited);
}
```

**anyMatch**, **noneMatch**, **allMatch** — these operations allow us to specify conditions and check if any, none, or all items in the stream match them.

> **Example**: we use the `**anyMatch**`, `**noneMatch**`, and `**allMatch**` operations to check if any, none, or all elements in the stream satisfy specific predicates. Each operation is chained to the stream of numbers, allowing us to efficiently evaluate the conditions.

```
    public static void main(String[] args) {
        List<Integer> numbers = List.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        assert Boolean.TRUE.equals( // Is any of the numbers equal to 5?
                numbers
                .stream()
                .anyMatch(num -> num == 5)
        );
        assert Boolean.FALSE.equals( // Is any of the numbers equal to 15?
                numbers
                        .stream()
                        .anyMatch(num -> num == 15)
        );
        assert Boolean.TRUE.equals( // None of the numbers is equal to 15
                numbers
                        .stream()
                        .noneMatch(num -> num == 15)
        );
        assert Boolean.FALSE.equals( // None of the numbers is equal to 3
                numbers
                        .stream()
                        .noneMatch(num -> num == 3)
        );
        assert Boolean.TRUE.equals( // All of the numbers are greater than 0
                numbers
                        .stream()
                        .allMatch(num -> num > 0)
        );
        assert Boolean.FALSE.equals( // All of the numbers are even
                numbers
                        .stream()
                        .allMatch(num -> num % 2 == 0)
        );
    }
```

### Advanced Examples

Combining multiple stream operations can lead to powerful and concise code. Here I will present some problems and then solutions to these problems using the Java Stream API based on a simple `**Employee**` model.

```
public class Advanced {
    enum Gender {
        MALE, FEMALE
    }
    record Employee(String name, int age, int salary, Gender gender) {
    }
    public static void main(String[] args) {
        Employee employee1 = new Employee("John", 20, 2000, Gender.MALE);
        Employee employee2 = new Employee("Jane", 28, 2000, Gender.FEMALE);
        Employee employee3 = new Employee("Alex", 38, 2750, Gender.MALE);
        Employee employee4 = new Employee("Mary", 35, 3500, Gender.FEMALE);
        Employee employee5 = new Employee("Pedro", 40, 3100, Gender.MALE);
        List<Employee> employees = List.of(employee1, employee2, employee3, employee4, employee5);
  
        // ...
    }
}
```

1.  **What is the total salary of male employees aged over 25?**

> By chaining `**filter**` and `**mapToDouble**` operations, we first filter male employees older than 25 and then map their salaries to double values. The `**sum**` operation then calculates the total salary of these filtered employees.

```
double summed = employees
                .stream()
                .filter(employee -> employee.gender.equals(Gender.MALE) && employee.age > 25)
                .mapToDouble(Employee::salary)
                .sum();
assert summed == 2750 + 3100;
```

**2. Does a female employee under the age of 30 named ‘Jane’ exist?**

> We filter the employees to include only those who are female and under the age of 30 using the `**filter**` operation. Then, we check if any of these filtered employees have the name “Jane” using the `**anyMatch**` operation with a lambda expression.

```
boolean existsFemaleEmployeeWithName = employees
        .stream()
        .filter(employee -> employee.gender.equals(Gender.FEMALE) && employee.age < 30)
        .anyMatch(employee -> employee.name.equals("Jane"));
assert existsFemaleEmployeeWithName;
```

**3. What is the total salary budget for all employees?**

> We first map each employee to their salary using the `**map**` operation. Then, we use the `**reduce**` operation to sum up all the salaries, starting with an initial value of 0.

```
Integer totalSalaryBudget = employees
        .stream()
        .map(Employee::salary)
        .reduce(0, Integer::sum);
assert totalSalaryBudget == 2000 + 2000 + 2750 + 3500 + 3100;
```

**4. What are the top three highest salaries among the employees?**

> We first map each employee to their salary using the `**_map_**` operation, leave only unique ones with `**distinct**`, sort them in descending order with `**sorted**`, and then select the top three highest salaries with `**limit**` operation.

```
List<Integer> top3HighestSalaries = employees
        .stream()
        .map(Employee::salary)
        .distinct()
        .sorted(Comparator.reverseOrder())
        .limit(3)
        .toList();
assert List.of(3500, 3100, 2750).equals(top3HighestSalaries);
```

**5.** **What is the total salary for each gender group among employees over the age of 20?**

> We `**filter**` the employees based on age criteria, `**collect**` them to a map grouping by gender to the total salary.

```
Map<Gender, Integer> genderToTotalSalaryMap = employees
        .stream()
        .filter(employee -> employee.age > 20)
        .collect(Collectors.groupingBy(Employee::gender, Collectors.summingInt(Employee::salary)));
assert genderToTotalSalaryMap.get(Gender.MALE) == 2750 + 3100;
assert genderToTotalSalaryMap.get(Gender.FEMALE) == 2000 + 3500;
```

These questions may not reflect the exact scenarios you encounter in your daily work, but they are similar enough. By mastering how to handle these simple tasks, you’ll quickly build the skills to tackle more complex problems with streams effortlessly.

### 🥁 5 Fun Facts About Streams

Would you like to hear some really interesting and fun facts about streams?

*   **Method Chaining
    **With streams, you can put many operations together in a chain.

```
List<String> words = Arrays.asList("apple", "banana", "cat", "dog");
long count = words.stream()          // Make a stream
    .filter(word -> word.length() > 3)  // Filter out short words
    .map(String::toUpperCase)           // Convert remaining words to uppercase
    .count();                           // Count how many words are left
```

> It’s like a conveyor belt for your data, where each step does something different to it (**hence the title picture of this tutorial**).

*   **Lazy Evaluation
    **Nothing happens in a stream until you need the result. Each step in the stream only happens when it’s needed, saving time and resources.

```
List<Integer> numbers = Arrays.asList(5, 12, 8, 3, 15, 20);
Integer result = numbers.stream()
    .filter(n -> n % 2 == 0) // Only even numbers
    .filter(n -> n > 10)     // Only numbers greater than 10
    .findFirst()              // Find the first matching number
    .orElse(null);            // Return null if no match
```

> The filtering is not performed immediately. Instead, it sets up the condition for filtering but waits until the stream is consumed or a terminal operation is applied.

*   **Parallel Processing
    **Streams can automatically use multiple threads to do work faster.

```
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
int sum = numbers.parallelStream() // Process in parallel
    .mapToInt(n -> n)              // Convert to IntStream
    .sum();                        // Add up all the numbers
```

> This can significantly improve performance for operations that can be parallelized, such as mapping, filtering, and reducing (_but be careful about which operations you decide to parallelize not to corrupt the results_).

*   **Immutable Data
    **Once you make a stream, you can’t change it.

```
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
List<String> upperCaseNames = names.stream() // Make a stream
    .map(String::toUpperCase)               // Make all names uppercase
    .collect(Collectors.toList());         // Collect into a new list
```

> Each operation on the stream makes a new stream. This helps to keep your data safe and makes it easier to understand your code.

*   **Optional**
    Streams often work hand-in-hand with `Optional` to handle potentially absent values.

```
Optional<String> firstFruit = fruits.stream() // Make a stream
    .findFirst();                             // Find the first fruit
```

> `**findFirst**` operation returns an `**Optional**` containing the first element of the stream, or an empty `**Optional**` if the stream is empty. This helps us gracefully handle the null values.

Sometimes there is more than 1 way to handle the problem using the stream operations, so be creative and try to play with your unique solutions. I encourage you to experiment with various combinations and scenarios yourself because practice is key to refining skills.

Of course, this tutorial is by no means intended to be a comprehensive guide to streams. It’s a deep topic with much to explore, and mastering it takes time. However, it serves as an attempt to share the stream operators I use daily and the problems they can solve.

I hope you enjoyed reading, and don’t forget to check out the exercises I’ve provided in [**my repository**](https://github.com/anitalakhadze/essential-stream-operations).

**_And stay tuned for the following tutorials!_**