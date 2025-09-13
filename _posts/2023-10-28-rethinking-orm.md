---
layout: post
title: Rethinking ORM
subtitle: Is jOOQ a Better Fit Than JPA for Your Project?
gh-repo: anitalakhadze/jOOQ-demo
gh-badge: [star, fork, follow]
tags: [jOOQ, JPA, ORM, Spring Boot, Maven]
comments: true
author: Ani Talakhadze
summary: This post explores the strengths and challenges of using JPA versus jOOQ for ORM in Java projects, focusing on scenarios where jOOQ’s flexible SQL approach outshines JPA’s limitations. Through practical examples and setup guides, it shows how jOOQ can make complex queries and database interactions more efficient, helping developers decide which tool fits their needs best.
---

If you’re like me, spending time checking out tutorials to improve your code, this is for you!

I was watching some talks from this year’s Spring I/O conference and one of the speakers got me excited about something called [jOOQ](https://www.youtube.com/watch?v=ykoUBctblno) (pronounced like [dʒuːk], trust me, I googled it 🤭).

While it’s true that when you’re planning a project, you should focus on the big picture first, the smaller details like which ORM to use can still be a pretty important decision — making your life easier or giving you a headache.

Now, we’ve all heard about JPA (Java Persistence API), right? It’s the go-to choice for ORM, the one everybody seems to use without thinking twice. But is that the best solution in all cases? That talk showed another possibility that may be more flexible and easy to interact with, so I decided to do some research and test it myself.

In this blog post, will will discuss how it compares to JPA and what are the cases in which it can lead to better performance. Also, we’re going to take a closer look at jOOQ and see how we can integrate it in a Spring Boot project.

The link to the source code repository will be added at the end of this tutorial.


# Typical Challenges Encountered with JPA  
I, for myself, often need to use complex conditions, sub queries or joins in JPQL to express the business logic behind the client requirements. So it’s the area I am currently mostly interested in and at the same time, it’s the one where most difficulties are encountered. Here’s why JPA can struggle in such scenarios:

1. **Query Generation**:  
    JPA generates corresponding SQL statements dynamically, introducing overhead and making queries less efficient.
2. **Optimization Limits**:  
    JPA’s query generation does not always produce the most optimized SQL code possible. Its generic approach to constructing queries can not take full advantage of database-specific optimizations.
3. **Native SQL Compatibility**:  
    While JPA does provide support for native SQL queries, they are not always portable across different database systems, causing potential risk for changing your database provider in the future.
4. **Potential for N+1 Query Problems**:  
    When dealing with complex relationships and eager loading of entities, JPA’s handling can lead to multiple queries, dragging down performance with extra database trips.
5. **Maintenance Challenges**:  
    JPA-built complex queries can get messy, making code tough to read and maintain.


# What about jOOQ?  
Let’s get a bit introduced to the officially advertised features of jOOQ. We will try to test some of the following points throughout this blog ourselves, but for now, let’s just list them:

1. **Focus on SQL**:  
    Writing SQL queries right in our Java code allows for greater control and flexibility as we can leverage our existing knowledge of the programming language to execute complex queries and implement database operations.
2. **Less Mistakes**:  
    Typos in column names or mix-ups with data types are identified early in the development cycle so no more time-consuming debugging sessions again, at least, in this section.
3. **Fast Queries**:  
    It utilizes query planning and execution algorithms that are tailored to the characteristics of the target database, thereby ensuring that the generated SQL statements are executed in the most efficient and resource-effective manner.


# Okay, okay, enough for the paper staff. Let’s get coding.  
First things first. Create a new Spring Boot project with a similar configuration:

<figure>
  <img src="https://i.imgur.com/yRBIC4E.png" alt="Trulli" style="width:100%">
  <figcaption><center>Spring Boot Project Configuration
</center></figcaption>
</figure>

Add the following dependencies for start:

<figure>
  <img src="https://i.imgur.com/s9qo2ot.png" alt="Trulli" style="width:100%">
  <figcaption><center>Browsing project dependencies
</center></figcaption>
</figure>

At first I tried to configure the project with H2 in-memory database, however, code generation was not working and was failing with the following error (even though, the schema was configured):

_[WARNING] No schemata were loaded : Please check your connection settings, and whether your database (and your database version!) is really supported by jOOQ. Also, check the case-sensitivity in your configured <inputSchema/> elements : [mySchema]_

Then I tried to modify the database url and store the data in file, but then the error message changed to this:

_The file is locked._

Then I gave up on H2. However, I was kindly provided with a link to a working example repository and you should be able to use H2 without any problems, following this [sample code](https://github.com/jOOQ/jOOQ-mcve) (there are examples for many other databases and that’s really nice).

I ran PostgreSQL instance on Docker locally with the following command (you can find more configuration options [here](https://hub.docker.com/_/postgres)):

```bash
docker run - name postgres-jooq-demo -e POSTGRES_PASSWORD=password -p 127.0.0.1:5432:5432 -d postgres
```

Then I copied the container ID from docker ps and ran the following commands to enter the container from outside and create a schema, table and some data inside:

```
docker exec -it [container ID] bash
psql -U postgres
create schema test_schema;
CREATE TABLE test_schema.countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
INSERT INTO test_schema.countries (name) VALUES ('United States');
INSERT INTO test_schema.countries (name) VALUES ('United Kingdom');
INSERT INTO test_schema.countries (name) VALUES ('France');
INSERT INTO test_schema.countries (name) VALUES ('Germany');
INSERT INTO test_schema.countries (name) VALUES ('Japan');
```

Alternatively, you could do the same by the nice database plugin inside IntelliJ IDE once you are connected to the instance:

<figure>
  <img src="https://i.imgur.com/Te8LG7a.png" alt="Trulli" style="width:100%">
  <figcaption><center>Data Source Configuration in Intellij
</center></figcaption>
</figure>

Don’t forget to add the database configuration in the application.properties file (modify it according to your needs) and test that the project is running without errors:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/postgres
spring.datasource.driverClassName=org.postgresql.Driver
spring.datasource.username=postgres
spring.datasource.password=password
```

Okay, now my database looks like this

<figure>
    <img src="https://i.imgur.com/5AX6IIy.png" alt="Trulli" style="width:100%">
    <figcaption><center>Table ‘countries’ inside the ‘test_schema’ in postgres database
</center></figcaption>
</figure>

Now comes the interesting part. In order to generate sources from Maven plugins, we need to add the following template populated with our configuration details (you can find more information in [jOOQ’s official tutorial](https://www.jooq.org/doc/latest/manual/code-generation/codegen-configuration/)):

```xml
   <plugin>
    <groupId>org.jooq</groupId>
    <artifactId>jooq-codegen-maven</artifactId>
    <executions>
     <execution>
      <id>jooq-codegen</id>
      <phase>generate-sources</phase>
      <goals>
       <goal>generate</goal>
      </goals>
     </execution>
    </executions>

    <configuration>
     <!--Insert your DB configuration-->
     <jdbc>
      <driver>org.postgresql.Driver</driver>
      <url>jdbc:postgresql://localhost:5432/postgres</url>
      <user>postgres</user>
      <password>password</password>
     </jdbc>
     <generator>
      <!-- The default code generator. You can override this one, to generate your own code style.
                         Supported generators:
                         - org.jooq.codegen.JavaGenerator
                         - org.jooq.codegen.KotlinGenerator
                         - org.jooq.codegen.ScalaGenerator
                         Defaults to org.jooq.codegen.JavaGenerator -->
      <name>org.jooq.codegen.JavaGenerator</name>

      <database>
       <!-- The database type. The format here is:
                            org.jooq.meta.[database].[database]Database -->
       <name>org.jooq.meta.postgres.PostgresDatabase</name>

       <!-- All elements that are generated from your schema
                            (A Java regular expression. Use the pipe to separate several expressions)
                            Watch out for case-sensitivity. Depending on your database, this might be important! -->
       <includes>.*</includes>

       <!-- All elements that are excluded from your schema
                            (A Java regular expression. Use the pipe to separate several expressions).
                            Excludes match before includes, i.e. excludes have a higher priority -->
       <excludes></excludes>

       <!-- The database schema (or in the absence of schema support, in your RDBMS this
                            can be the owner, user, database name) to be generated -->
       <inputSchema>test_schema</inputSchema>
      </database>
      <generate>
       <pojos>true</pojos>
       <pojosEqualsAndHashCode>true</pojosEqualsAndHashCode>
       <javaTimeTypes>true</javaTimeTypes>
       <fluentSetters>true</fluentSetters>
      </generate>
      <target>
       <!-- The destination package of your generated classes
                            (within the destination directory) -->
       <packageName>model</packageName>

       <!-- The destination directory of your generated classes.
                            Using Maven directory layout here -->
       <directory>target/generated-sources/jooq</directory>
      </target>
     </generator>
    </configuration>
   </plugin>
```

Pay attention to the target package name and directory as it’s where the classes will be stored after generation, so the path should be correct. In the end, my pom.xml file looks like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
 <modelVersion>4.0.0</modelVersion>
 <parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>3.1.4</version>
  <relativePath/> <!-- lookup parent from repository -->
 </parent>
 <groupId>com.anita</groupId>
 <artifactId>jOOQ-demo</artifactId>
 <version>0.0.1-SNAPSHOT</version>
 <name>jOOQ-demo</name>
 <description>jOOQ-demo</description>
 <properties>
  <java.version>17</java.version>
 </properties>
 <dependencies>
  <dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-jooq</artifactId>
  </dependency>
  <dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-web</artifactId>
  </dependency>

  <dependency>
   <groupId>org.postgresql</groupId>
   <artifactId>postgresql</artifactId>
   <version>42.6.0</version>
  </dependency>

  <dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-test</artifactId>
   <scope>test</scope>
  </dependency>
 </dependencies>

 <build>
  <plugins>
   <plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
   </plugin>

   <plugin>
    <groupId>org.jooq</groupId>
    <artifactId>jooq-codegen-maven</artifactId>
    <executions>
     <execution>
      <id>jooq-codegen</id>
      <phase>generate-sources</phase>
      <goals>
       <goal>generate</goal>
      </goals>
     </execution>
    </executions>

    <configuration>
     <!--Insert your DB configuration-->
     <jdbc>
      <driver>org.postgresql.Driver</driver>
      <url>jdbc:postgresql://localhost:5432/postgres</url>
      <user>postgres</user>
      <password>password</password>
     </jdbc>
     <generator>
      <!-- The default code generator. You can override this one, to generate your own code style.
                         Supported generators:
                         - org.jooq.codegen.JavaGenerator
                         - org.jooq.codegen.KotlinGenerator
                         - org.jooq.codegen.ScalaGenerator
                         Defaults to org.jooq.codegen.JavaGenerator -->
      <name>org.jooq.codegen.JavaGenerator</name>

      <database>
       <!-- The database type. The format here is:
                            org.jooq.meta.[database].[database]Database -->
       <name>org.jooq.meta.postgres.PostgresDatabase</name>

       <!-- All elements that are generated from your schema
                            (A Java regular expression. Use the pipe to separate several expressions)
                            Watch out for case-sensitivity. Depending on your database, this might be important! -->
       <includes>.*</includes>

       <!-- All elements that are excluded from your schema
                            (A Java regular expression. Use the pipe to separate several expressions).
                            Excludes match before includes, i.e. excludes have a higher priority -->
       <excludes></excludes>

       <!-- The database schema (or in the absence of schema support, in your RDBMS this
                            can be the owner, user, database name) to be generated -->
       <inputSchema>test_schema</inputSchema>
      </database>
      <generate>
       <pojos>true</pojos>
       <pojosEqualsAndHashCode>true</pojosEqualsAndHashCode>
       <javaTimeTypes>true</javaTimeTypes>
       <fluentSetters>true</fluentSetters>
      </generate>
      <target>
       <!-- The destination package of your generated classes
                            (within the destination directory) -->
       <packageName>model</packageName>

       <!-- The destination directory of your generated classes.
                            Using Maven directory layout here -->
       <directory>target/generated-sources/jooq</directory>
      </target>
     </generator>
    </configuration>
   </plugin>

  </plugins>
 </build>

</project>
```

Don’t forget to reload pom.xml after adding that plugin. Once the file is reloaded, you will see a new plugin appear in maven tools:

<figure>
  <img src="https://i.imgur.com/J9l39gU.png" alt="Trulli" style="width:100%">
  <figcaption><center>jOOQ codegen plugin in Maven
</center></figcaption>
</figure>

When you click the plugin, after several seconds, hopefully, you should see a build success message and a similar result:

<figure>
  <img src="https://i.imgur.com/H6RFYNH.png" alt="Trulli" style="width:100%">
  <figcaption><center>Sources generated by jooq codegen plugin
</center></figcaption>
</figure>

In this tables package we have a class for each table. These classes contain information about the tables and its static name (which should be used in SQL statements generation). records package contains classes that would be the result of an SQL statement in that particular table.

Additionally, jOOQ can generate data models from flyway or liquibase scripts, although this capability appears somewhat limited.

Now let’s see how we can actually use the generated sources in code. Create a new class with this configuration (needed to access DSL context later and communicate with the database through jOOQ):

```java
@Configuration
public class DslConfiguration {

    private final DataSource dataSource;

    public InitialConfiguration(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Bean
    public DataSourceConnectionProvider connectionProvider() {
        return new DataSourceConnectionProvider(new TransactionAwareDataSourceProxy(dataSource));
    }

    @Bean
    public DefaultDSLContext dsl() {
        return new DefaultDSLContext(configuration());
    }

    public DefaultConfiguration configuration() {
        DefaultConfiguration jooqConfiguration = new DefaultConfiguration();
        jooqConfiguration.set(connectionProvider());
        return jooqConfiguration;
    }
}
```

Having done that, change the code in the main application class with this:

```java
@SpringBootApplication
public class JOoqDemoApplication {

 private final DefaultDSLContext dsl;

 public JOoqDemoApplication(DefaultDSLContext dsl) {
  this.dsl = dsl;
 }

 public static void main(String[] args) {
  SpringApplication.run(JOoqDemoApplication.class, args);
 }

 @PostConstruct
 public void post() {
  CountriesRecord countriesRecord = dsl
    .select()
    .from(Tables.COUNTRIES)
    .where(Tables.COUNTRIES.ID.eq(1))
    .fetchOneInto(Tables.COUNTRIES);
        assert countriesRecord != null;
        System.out.printf("FIRST COUNTRY: %s%n", countriesRecord.getName());

  CountriesRecord countriesRecord1 = dsl
    .select()
    .from(Tables.COUNTRIES)
    .where(Tables.COUNTRIES.NAME.like("%Jap%"))
    .fetchOneInto(Tables.COUNTRIES);
  assert countriesRecord1 != null;
  System.out.printf("%s is also in the list%n;", countriesRecord1.getName());
 }

}
```

While it’s not an example of coding best practices, it will still do us a good job for testing that the jOOQ actually works in our application. In the first case, we are trying to fetch a record the ID of which is equal to 1 and in the second case, we are trying to search for a record the name of which is like the prompt. Writing SQL statements in an object-oriented way really felt nice, I must admit.

It should be mentioned, that projection in jOOQ is always a read-only. We can also use java record to project the data to.

Depending on your table content and app configuration, you should see an output similar to this, after you run the project:

<figure>
    <img src="https://i.imgur.com/SAhIY1k.png" alt="Trulli" style="width:100%">
    <figcaption><center>Application output after running
</center></figcaption>
</figure>

The text banner looks really cute and also, they are providing a tip of the day on each run (above the highlighted area in logs) that is very nice of them too.

Okay, all this was not quite easy and you can argue with me, even more difficult than doing the same in JPA. However, as I mentioned in the beginning, I am more interested in complex scenarios.

For a bit more complex example, suppose we want to find the countries that have a population larger than the average population of all countries. We’ll join the COUNTRIES and POPULATION tables and use a subquery to calculate the average population. Here's the SQL query:

```sql
SELECT c.country_name
FROM countries c
JOIN population p ON p.country_id = c.id
WHERE p.population_count > (SELECT AVG(population_count) FROM population);
```

The above query expressed in jOOQ would be something like this:

```java
@SpringBootTest
@ExtendWith(SpringExtension.class)
public class JooqVeryComplexQueryExample {

    @Autowired
    private DSLContext dslContext; // Autowire the DSLContext

    @Test
    public void testJooqComplexQuery() {
        Field<Integer> avgPopulation = DSL.select(DSL.avg(POPULATION.POPULATION_COUNT))
                .from(POPULATION)
                .asField("avg_population");

        Result<Record1<String>> result = dslContext
                .select(COUNTRIES.COUNTRY_NAME)
                .from(COUNTRIES)
                .join(POPULATION).on(POPULATION.COUNTRY_ID.eq(COUNTRIES.ID))
                .where(POPULATION.POPULATION_COUNT.gt(avgPopulation))
                .fetch();

        // Print the results
        for (Record r : result) {
            System.out.println("Country: " + r.get(0));
        }
    }
}
```

If you have to deal with complicated queries and special conditions in JPQL, it might take a lot of time and effort, especially if your database has specific fancy features that JPQL can’t handle directly.

That's where jOOQ comes in handy. For example, jOOQ efficiently offers the multiset feature, commonly supported by most databases, enabling the use of inner selects. This functionality significantly simplifies the process, allowing for easy data mapping to desired DTOs. In JPA, achieving the same result would typically involve multiple SQL statements, leading to cumbersome and less efficient practices.

You can see the extended user manual here on the official web page. It’s very well documented.

# When to Choose jOOQ Over JPA?  
When deciding between JPA and jOOQ, think about your project requirements and team expertise. Consider factors like query complexity, performance, legacy database support, SQL preferences, and pricing (jOOQ is free for open-source databases but requires [payment for commercial ones](https://www.jooq.org/download/price-plans)).

I found jOOQ especially useful in CRUD applications, avoiding complex operations and entity checks. It simplifies the handling of SQL statements and nested business logic, providing efficient data mapping and logging functionalities (The best part? It automatically includes the query’s parameters, eliminating the need for manual parameter insertion during debugging).

On the other hand, writing Java code for CRUD in jOOQ can be laborious and delicate, unlike the smoother experience with JPA\Hibernate. Maintaining and testing the repository layer in larger projects becomes time-consuming, risking unintended disruptions across the codebase.

Furthermore, with jOOQ, I have not tried setting up a project with multiple data sources and that would be quite interesting to test too.

In the end, both JPA and jOOQ have their strengths and weaknesses. While jOOQ offers control and efficiency, JPA\Hibernate provides convenience and stability. It’s essential to choose based on your project’s specific needs and your team’s capabilities.

Feel free to share your insights on these points in the comments.

<center>* * *</center>

In this blog we tried to discuss different case scenarios in which you may want to consider alternative options instead of JPA for your application and demonstrated a simple case for jOOQ usage. If interested, you can further explore its capabilities with their [official documentation](https://www.jooq.org/learn/) or view some of the [demo projects](https://github.com/jOOQ/demo).

If you have missed anything, all code can be found on my [GitHub repository](https://github.com/anitalakhadze/jOOQ-demo).

Let me know if you have any questions, comments, or suggestions for the upcoming content.

**Stay tuned and don’t miss the following blogs!**