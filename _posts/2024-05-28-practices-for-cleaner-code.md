---
layout: post
title: Practices I Try to Follow for Cleaner Code
author: Ani Talakhadze
summary: Personal Tips for Improving Your Code Quality
---

![captionless image](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*W4OUior5OO-h1lWjQvTcmg.png)

Writing clean code is crucial for maintaining and scaling any application. This is not just a catchphrase but a fact. Clean code is easy to read, understand, and modify. In my own experience, it has often been more important than quickly wrapping up a solution. Trust me, your teammates (current and future ones) will be forever grateful for your efforts.

Here are the top 10 approaches to writing cleaner code that I have found to improve readability and maintainability for myself and my colleagues. Although these examples are in Java, I believe they are not limited to a specific language or framework. Rather, they are part of a mindset that can be applied to any tool or technology.

You will find the repository with the code on [**my GitHub page**](https://github.com/anitalakhadze/clean-code-best-practices). Don’t forget to check it out and compare the differences yourself, play with it to improve it even more, and let me know your thoughts and personal tips down in the comments.

# Use Meaningful Names
------------------------

> **What is a bad practice?**
> 
> Poorly named variables, methods, and classes do not convey any meaning. They don’t inform the reader about their responsibilities, leading to potential mistakes or incorrect interpretations by the developer.

```
public class NamingBadPractice {
    static class Handler {
        private static final double MAX_AMOUNT = 100.0;
        private final String provider;
        private final Map<String, Double> transactions;
        public Handler(String provider) {
            this.provider = provider;
            this.transactions = new HashMap<>();
        }
        public void pay(String customerName, double amount) {
            System.out.println("Pmt process $" + amount + " for customer " + customerName + " via " + provider);
            check(amount);
            transactions.put(customerName, transactions.getOrDefault(customerName, 0.0) + amount);
        }
        public void check(double amount) {
            if (amount > MAX_AMOUNT) {
                throw new RuntimeException("Cannot process more than " + MAX_AMOUNT + " per transaction");
            }
        }
        public void returnBack(String customerName, double amount) {
            System.out.println("Refund $" + amount + " for customer " + customerName);
            double currentAmount = transactions.getOrDefault(customerName, 0.0);
            checkAmount(currentAmount, amount);
            transactions.put(customerName, currentAmount - amount);
        }
        public void checkAmount(double currentAmount, double amount) {
            if (currentAmount < amount) {
                throw new RuntimeException("Insufficient balance to refund.");
            }
        }
        public void getReceipt(String customerName) {
            double total = transactions.getOrDefault(customerName, 0.0);
            System.out.println("Generating receipt for customer " + customerName + " for total $" + total);
        }
        public static void main(String[] args) {
            Handler ph = new Handler("Stripe");
            ph.pay("Alice", 100.0);
            ph.pay("Bob", 150.0);
            ph.returnBack("Alice", 50.0);
            ph.getReceipt("Alice");
            ph.getReceipt("Bob");
        }
    }
}
```

> **How can it be improved?**
> 
> Instead of using confusing names, use descriptive ones to make the code self-explanatory. Variables like `transactionHistory` or methods like `validateSufficientBalanceForRefund` clearly communicate their purpose.

```
public class NamingGoodPractice {
    static class PaymentHandler {
        private static final double MAX_TRANSACTION_AMOUNT = 100.0;
        private final String paymentGateway;
        private final Map<String, Double> transactionHistory;
        public PaymentHandler(String paymentGateway) {
            this.paymentGateway = paymentGateway;
            this.transactionHistory = new HashMap<>();
        }
        public void processPayment(String customerName, double amount) {
            System.out.println("Processing payment of $" + amount + " for customer " + customerName + " via " + paymentGateway);
            validateTransactionAmount(amount);
            transactionHistory.put(customerName, transactionHistory.getOrDefault(customerName, 0.0) + amount);
        }
        public void validateTransactionAmount(double amount) {
            if (amount > MAX_TRANSACTION_AMOUNT) {
                throw new RuntimeException("Cannot process more than " + MAX_TRANSACTION_AMOUNT + " per transaction");
            }
        }
        public void refundPayment(String customerName, double amount) {
            System.out.println("Refunding $" + amount + " for customer " + customerName);
            double currentBalance = transactionHistory.getOrDefault(customerName, 0.0);
            validateSufficientBalanceForRefund(currentBalance, amount);
            transactionHistory.put(customerName, currentBalance - amount);
        }
        public void validateSufficientBalanceForRefund(double currentBalance, double amount) {
            if (currentBalance < amount) {
                throw new RuntimeException("Insufficient balance to refund.");
            }
        }
        public void generateReceipt(String customerName) {
            double totalAmount = transactionHistory.getOrDefault(customerName, 0.0);
            System.out.println("Generating receipt for customer " + customerName + " for total amount $" + totalAmount);
        }
        public static void main(String[] args) {
            PaymentHandler paymentHandler = new PaymentHandler("Stripe");
            paymentHandler.processPayment("Alice", 100.0);
            paymentHandler.processPayment("Bob", 150.0);
            paymentHandler.refundPayment("Alice", 50.0);
            paymentHandler.generateReceipt("Alice");
            paymentHandler.generateReceipt("Bob");
        }
    }
}
```

# Follow the Single Responsibility Principle (SRP)
----------------------------------------------------

> **What is a bad practice?**
> 
> When a class handles multiple responsibilities, it becomes complex and harder to understand. This can create dependencies between unrelated components, increasing the chance of bugs. Additionally, it makes writing comprehensive tests difficult, as the class has multiple reasons to change.

```
public class SingleResponsibilityBadPractice {
    static class Task {
        private String name;
    }
    static class Employee {
        private String name;
        private String role;
        public void saveEmployee(Employee employee) {
            System.out.println("Saving employee data to database");
        }
        public void updateEmployee(Employee employee) {
            System.out.println("Updating employee data in database");
        }
        public void deleteEmployee(Employee employee) {
            System.out.println("Deleting employee data from database");
        }
        public void assignTask(Task task) {
            System.out.println("Assigning task to employee");
        }
        public void completeTask(Task task) {
            System.out.println("Completing task assinged to employee");
        }
        public void cancelTask(Task task) {
            System.out.println("Cancelling task assigned to employee");
        }
    }
}
```

> **What is a better approach?**
> 
> When classes follow the SRP, they become more modular and reusable. This ensures that changes or updates do not affect other parts of the class. By delegating different responsibilities to different classes, each class has a single reason to change, simplifying maintenance and improving readability and testability.

```
public class SingleResponsibilityGoodPractice {
    static class Task {
        private String name;
    }
    static class Employee {
        private String name;
        private String role;
        public void saveEmployee(SingleResponsibilityBadPractice.Employee employee) {
            System.out.println("Saving employee data to database");
        }
        public void updateEmployee(SingleResponsibilityBadPractice.Employee employee) {
            System.out.println("Updating employee data in database");
        }
        public void deleteEmployee(SingleResponsibilityBadPractice.Employee employee) {
            System.out.println("Deleting employee data from database");
        }
    }
    static class TaskManager {
        public void assignTask(Task task) {
            System.out.println("Assigning task to employee");
        }
        public void completeTask(Task task) {
            System.out.println("Completing task assinged to employee");
        }
        public void cancelTask(Task task) {
            System.out.println("Cancelling task assigned to employee");
        }
    }
}
```

# Shorten Methods
-------------------

> **What is a bad practice?**
> 
> When a method is too long, it becomes harder to understand, maintain, and debug. Long methods often mix multiple responsibilities, increasing complexity and the likelihood of bugs.

```
public class ConciseMethodsBadPractice {
    public void processOrder(Order order) {
        if (order == null) {
            throw new IllegalArgumentException("Order cannot be null");
        }
        if (Objects.isNull(order.getItems()) || order.getItems().isEmpty()) {
            throw new IllegalArgumentException("Order must have at least one item");
        }
        if (Objects.isNull(order.getCustomer())) {
            throw new IllegalArgumentException("Order must have a customer");
        }
        for (OrderItem item : order.getItems()) {
            if (item.quantity() <= 0) {
                throw new IllegalArgumentException("Item quantity must be greater than zero");
            }
            if (item.price() < 0) {
                throw new IllegalArgumentException("Item price cannot be negative");
            }
        }
        double total = 0;
        for (OrderItem item : order.getItems()) {
            double itemTotal = item.quantity() * item.price();
            total += itemTotal;
        }
        double tax = total * 0.1; // Example tax calculation
        double discount = total > 100 ? 10 : 0; // Example discount logic
        double finalTotal = total + tax - discount;
        order.setSubTotal(total);
        order.setTax(tax);
        order.setDiscount(discount);
        order.setTotal(finalTotal);
        System.out.println("Saving order to the database...");
        System.out.println("Order Details:");
        System.out.println("Customer: " + order.getCustomer().name());
        System.out.println("Subtotal: $" + total);
        System.out.println("Tax: $" + tax);
        System.out.println("Discount: $" + discount);
        System.out.println("Total: $" + finalTotal);
        System.out.println("Order saved successfully.");
    }
    public static class Order {
        private List<OrderItem> items;
        private Customer customer;
        private double subTotal;
        private double tax;
        private double discount;
        private double total;
        // constructor, getters and setters
    }
    public record OrderItem(String name, int quantity, double price) {}
    public record Customer(String name) {}
}
```

> **How can it be improved?**
> 
> Breaking long methods into smaller, focused ones makes code less error-prone and more maintainable. It also simplifies debugging and improves clarity. Style guides typically recommend keeping methods around 20–30 lines. If a method exceeds this, it’s often a sign that the algorithm is too complex or the method is trying to do too much.

```
public class ConciseMethodsGoodPractice {
    public void processOrder(Order order) {
        validateOrder(order);
        calculateOrderTotal(order);
        saveOrder(order);
    }
    private void validateOrder(Order order) {
        if (Objects.isNull(order)) {
            throw new IllegalArgumentException("Order cannot be null");
        }
        if (Objects.isNull(order.getItems()) || order.getItems().isEmpty()) {
            throw new IllegalArgumentException("Order must have at least one item");
        }
        if (Objects.isNull(order.getCustomer())) {
            throw new IllegalArgumentException("Order must have a customer");
        }
        for (OrderItem item : order.getItems()) {
            if (item.quantity() <= 0) {
                throw new IllegalArgumentException("Item quantity must be greater than zero");
            }
            if (item.price() < 0) {
                throw new IllegalArgumentException("Item price cannot be negative");
            }
        }
    }
    private void calculateOrderTotal(Order order) {
        double subtotal = 0;
        for (OrderItem item : order.getItems()) {
            double itemTotal = item.quantity() * item.price();
            subtotal += itemTotal;
        }
        double tax = subtotal * 0.1; // Example tax calculation
        double discount = subtotal > 100 ? 10 : 0; // Example discount logic
        double total = subtotal + tax - discount;
        order.setSubTotal(subtotal);
        order.setTax(tax);
        order.setDiscount(discount);
        order.setTotal(total);
    }
    private void saveOrder(Order order) {
        System.out.println("Saving order to the database...");
        System.out.println("Order Details:");
        System.out.println("Customer: " + order.getCustomer().name());
        System.out.println("Subtotal: $" + order.getSubTotal());
        System.out.println("Tax: $" + order.getTax());
        System.out.println("Discount: $" + order.getDiscount());
        System.out.println("Total: $" + order.getTotal());
        System.out.println("Order saved successfully.");
    }
    public static class Order {
        private List<OrderItem> items;
        private Customer customer;
        private double subTotal;
        private double tax;
        private double discount;
        private double total;
        // constructor, getters and setters
    }
    public record OrderItem(String name, int quantity, double price) {}
    public record Customer(String name) {}
}
```

# Using Comments In a Meaningful Way
--------------------------------------

> **What is a bad practice?**
> 
> Overusing comments or adding comments that just restate what the code is doing are redundant and do not add any value. Additionally, outdated or incorrect comments can mislead developers and cause confusion.

```
public class CommentsBadPractice {
    private double balance;
    // Constructor to set the balance
    public CommentsBadPractice(double initialBalance) {
        // Set the initial balance
        this.balance = initialBalance;
    }
    // Add to balance
    public void addToBalance(double amount) {
        this.balance += amount; // Add the amount to the balance
    }
    // Subtract amount from balance
    public void subtractFromBalance(double amount) {
        this.balance -= amount; // Subtract the amount from the balance
    }
    // Print the current balance
    public void printBalance() {
        System.out.println("Current balance: " + this.balance); // Print the balance
    }
    
}
```

> **What is a better approach?**
> 
> Use comments to explain the purpose and the reasoning behind the code, especially for complex or non-obvious logic. Good comments help other developers (and your future self) understand why certain decisions were made, without stating the obvious. Also, don’t forget to update the comments if logic has been modified.

```
public class CommentsGoodPractice {
    /**
     * Formats a full name from given first name, middle name, and last name.
     * The middle name is optional and should be handled appropriately.
     *
     * @param firstName  the user's first name
     * @param middleName the user's middle name (can be null or empty)
     * @param lastName   the user's last name
     * @return the formatted full name
     */
    public String formatFullName(String firstName, String middleName, String lastName) {
        firstName = firstName.trim();
        lastName = lastName.trim();
        if (Objects.nonNull(middleName) && !middleName.isBlank()) {
            middleName = middleName.trim();
            return String.format("%s %s %s", firstName, middleName, lastName);
        }
        return String.format("%s %s", firstName, lastName);
    }
    
}
```

# Consistent Formatting
-----------------------------

> **What is a bad practice?**
> 
> Inconsistent formatting makes it hard for developers to quickly understand the code’s structure and logic. It also complicates having a standard style throughout the codebase and leads to a poor-quality code.

```
public class FormattingBadPractice {
    public static void main(String[] args) {
        int x=10;
        int y = 20 ;
         int result = x+y ;
        System.out.println("The result is: " +result);
    }
}
```

> **How can it be improved?**
> 
> Though it may seem minor, consistent formatting greatly improves readability and teamwork. There are many tools that can assist with coding standards for indentation and spacing. Plus, it’s just one shortcut away in any IDE.

```
public class FormattingGoodPractice {
    public static void main(String[] args) {
        int x = 10;
        int y = 20;
        int result = x + y;
        
        System.out.println("The result is: " + result);
    }
}
```

# Provide Meaningful Error Messages
-------------------------------------

> **What is a bad practice?**
> 
> Catching a generic Exception and just printing the stack trace is not helpful. It provides minimal information and no specific handling for different errors. Yet, providing general error messages, that only state the obvious and not communicate any specificity, is even worse. The receiver of the message will struggle to understand what went wrong.

```
public class ErrorMessagesBadPractice {
    public static void main(String[] args) {
        try {
            readFile("example.txt");
            executeDatabaseQuery("INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com')");
            performGenericOperation();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    private static void readFile(String fileName) throws IOException {
        try (BufferedReader reader = new BufferedReader(new FileReader(fileName))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        }
    }
    private static void executeDatabaseQuery(String query) throws SQLException {
        String url = "jdbc:mysql://localhost:3306/mydatabase";
        String user = "root";
        String password = "password";
        try (Connection connection = DriverManager.getConnection(url, user, password);
             Statement statement = connection.createStatement()) {
            statement.executeUpdate(query);
        }
    }
    private static void performGenericOperation() throws Exception {
        throw new Exception("Generic error.");
    }
}
```

> **How can it be improved?**
> 
> By catching specific exceptions and providing meaningful error messages, it becomes easier to debug and understand errors. Moreover, logging exceptions with a logger, instead of printing the stack trace, integrates errors into a centralized logging system, making them easier to manage and monitor.

```
public class ErrorMessagesGoodPractice {
    private static final Logger logger = Logger.getLogger(ErrorMessagesGoodPractice.class.getName());
    public static void main(String[] args) {
        try {
            readFile("example.txt");
            executeDatabaseQuery("INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com')");
            performGenericOperation();
        } catch (IOException e) {
            logger.log(Level.SEVERE, "Failed to read file", e);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error occurred", e);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error", e);
        }
    }
    private static void readFile(String fileName) throws IOException {
        try (BufferedReader reader = new BufferedReader(new FileReader(fileName))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        }
    }
    private static void executeDatabaseQuery(String query) throws SQLException {
        String url = "jdbc:mysql://localhost:3306/mydatabase";
        String user = "root";
        String password = "password";
        try (Connection connection = DriverManager.getConnection(url, user, password);
             Statement statement = connection.createStatement()) {
             statement.executeUpdate(query);
        }
    }
    private static void performGenericOperation() throws Exception {
        throw new Exception("An unexpected error occurred during a generic operation");
    }
}
```

# Keep Your Code Within the Margin Lines
------------------------------------------

> **What is a bad practice?**
> 
> Exceeding the margin lines in your IDE can make your code hard to read and maintain. Long lines require endless scrolling, disrupting the flow and productivity. It also complicates code reviews and understanding for team members, possibly leading to errors.

```
public class LineMarginsBadPractice {
    public static class OrderProcessor {
        
        public void processOrder(String orderId, String customerName, String customerEmail, String shippingAddress, String billingAddress, double orderTotal, String paymentMethod, String deliveryInstructions, boolean giftWrap, boolean expeditedShipping) {
            System.out.println("Processing order: " + orderId + " for customer: " + customerName + " with total amount: " + orderTotal);
            // Additional processing logic...
        }
        
    }
    
}
```

> **What is a better approach?**
> 
> Keeping your code within the margin lines makes it easy to scan quickly. IDEs often offer guidelines, usually at 80 or 100 characters per line (number is customizable), to help follow this practice. For instance, IntelliJ IDEA even provides a visual representation of the margin. Moreover, breaking long lines into smaller pieces also promotes better coding practices, like encapsulating logic into well-named methods and classes. This simplifies code reviews and collaboration, as team members can quickly grasp the code’s structure and intent without long lines getting in the way.

```
public class LineMarginGoodPractice {
    public static class OrderProcessor {
        public void processOrder(Order order) {
            System.out.println("Processing order: " + order.getOrderId() +
                    " for customer: " + order.getCustomerName() +
                    " with total amount: " + order.getOrderTotal());
            // Additional processing logic...
        }
    }
    
    public static class Order {
        private String orderId;
        private String customerName;
        private String customerEmail;
        private String shippingAddress;
        private String billingAddress;
        private double orderTotal;
        private String paymentMethod;
        private String deliveryInstructions;
        private boolean giftWrap;
        private boolean expeditedShipping;
        // Constructor, getters, and setters...
    }
    
}
```

# Write Meaningful Test Cases
-------------------------------

> **What is a bad practice?**
> 
> Skipping tests and leaving code to chance is not recommendable, to say the least. Without tests, it’s uncertain if changes will break the code and I would argue, that writing tests deserves its own paragraph. However, I want to stress a different point here. Writing tests just to fulfill a requirement without ensuring they actually verify behavior or at least, describe the behavior that they need to verify, is problematic.

```
    @Test
    void nameIsFormatted() {
        assertEquals(
                "firstName middleName lastName",
                CommentsGoodPractice.formatFullName(
                        "firstName",
                        "middleName",
                        "lastName"
                )
        );
    }
```

> **What is a better approach?**
> 
> Effective tests are clear, concise, and focused on verifying specific behaviors of your code, including normal conditions, boundary cases, and potential errors. They should be easy to understand for other developers, making it clear what is being tested and why. Remember, no one knows your code better than you do, so it’s especially important to test the cases that you know may be overlooked during manual or automated testing.

```
class CommentsGoodPracticeTest {
    @Test
    void whenMiddleNameIsBlank_nameIsCorrectlyFormatted() {
        assertEquals(
                "firstName lastName",
                CommentsGoodPractice.formatFullName(
                        "firstName",
                        "    ",
                        "lastName")
        );
    }
    @Test
    void whenMiddleNameIsNull_nameIsCorrectlyFormatted() {
        assertEquals(
                "firstName lastName",
                CommentsGoodPractice.formatFullName(
                        "firstName",
                        null,
                        "lastName"
                )
        );
    }
    @Test
    void whenMiddleNameIsEmpty_nameIsCorrectlyFormatted() {
        assertEquals(
                "firstName lastName",
                CommentsGoodPractice.formatFullName(
                        "firstName",
                        "",
                        "lastName"
                )
        );
    }
    @Test
    void whenFullNameIsProvided_nameIsCorrectlyFormatted() {
        assertEquals(
                "firstName middleName lastName",
                CommentsGoodPractice.formatFullName(
                        "firstName",
                        "middleName",
                        "lastName"
                )
        );
    }
}
```

# Have Your Code Reviewed
---------------------------

> **What is a bad practice?**
> 
> Skipping code reviews can result in unnoticed errors, inconsistencies, and low-quality code. It’s a missed chance to catch bugs early, enhance code quality, and share knowledge with team members. Moreover, if your code is reviewed and comments or recommendations are left, ignoring them, even if you don’t agree, is not advisable. This can cause a decrease in team motivation.
> 
> **What is a better approach?**
> 
> Regular code reviews are crucial for ensuring quality, consistency, and maintainability. The importance of code reviews for knowledge sharing and identifying potential issues upfront can’t be emphasized enough. Never be lazy to do that. It is even more important to always respond to those who take the time to review and comment on your code. Acknowledge their feedback to show that their voice is heard and their opinion is appreciated. This nurtures team culture and strengthens relationships.

# Constantly improve your approach
-------------------------------------

> **What is a bad practice?**
> 
> Sticking to any approach blindly without evaluating the case at hand and adapting can lead to inefficient code, and strained team relations too for that matter. This inflexibility can result in overly complex, hard-to-understand code that doesn’t meet evolving project needs.
> 
> **What is a better approach?**
> 
> Understanding when to prioritize clarity over conciseness, simplicity over complexity, and specificity over generality is crucial for writing effective code and being a professional team member. Aim to strike the right balance based on the task at hand, but always remember that most developers spend more time reading other people’s code than writing their own. Ensure your code is as easy to understand as you would want others’ code to be.

I would advise you to take the time to write clean code. It’s an investment that saves resources for you and your teammates in the future. Of course, this article does not include all the approaches that people find helpful. This was just a collection of my personal favorites — practices that I believe have led to better code quality overall.

To be clear, I myself have failed to follow them many times, but ultimately, our most important goal is to maintain discipline in constantly reflecting on our work and always be willing to improve, isn’t it?

Finally, I want to recommend [**this excellent book**](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882) by _Robert C. Martin_. What makes it so spacial and absolutely favorite for many developers is that it is driven by facts, statistics and personal experiences. I would even go further and state that it’s a must-read for every engineer.

Stay tuned for the following blogs_** ✨