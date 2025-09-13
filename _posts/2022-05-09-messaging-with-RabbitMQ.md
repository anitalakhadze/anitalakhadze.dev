---
layout: post
title: Part 4 - HOW TO
subtitle: Configure messaging with RabbitMQ in a Spring Boot application
gh-repo: anitalakhadze/rabbitmq-exchange-demo
gh-badge: [star, fork, follow]
tags: [RabbitMQ, Spring Boot, Maven, Messaging, Java]
comments: true
author: Ani Talakhadze
summary: This guide walks you through setting up message-based communication in a Spring Boot application using RabbitMQ and Spring AMQP. It explains core messaging concepts, shows how to configure fanout and topic exchanges, and demonstrates how to build producers and consumers for practical microservice integration.
---

If you’re interested in microservices and haven’t yet encountered message-based communication, trust me when I say you will.

In this tutorial of the HOW TO series, I am going to give you a practical example of using RabbitMQ messaging configuration inside a Spring Boot application. We will build an application that publishes a message by using Spring AMQP’s RabbitTemplate and subscribes to the message by using RabbitListener.

As you may be a bit confused at first, like me, let’s cover some of the key concepts of messaging first before we dive into details.

The link to the source code repository will be added at the end of this tutorial.

## What is a message-based communication?  

Messaging is a method of transferring data between applications. We normally develop our applications using a synchronous request-response architecture. However, such approach becomes insufficient and not reliable in case of microservices as it fails to have consistency between multiple data sources across our distributed system. Instead, we have to rely on exchanging messages asynchronously.

RabbitMQ, for instance, is exactly one of the providers of such a solution. It sits between message producers and consumers, acting as an intermediary messaging layer and providing useful features like persistent message storage, message filtering, and message transformation.

You may be a bit surprised, but Java has its own Message Service (JMS) API for messaging between applications. However, due to vendor and platform interoperability, we are unable to use JMS clients and brokers. This is where AMQP saves the day.


## What is AMQP?  

According to a definition:

<!-- block quote -->
> Advanced Message Queuing Protocol (AMQP) is created as an open standard protocol that allows messaging interoperability between systems, regardless of message broker vendor or platform used; With AMQP, you can use whatever AMQP-compliant client library you want, and any AMQP-compliant broker you want. Message clients using AMQP are completely agnostic.

This means that AMQP is just a specification, providing a set of standards of how the entire messaging process should be controlled via AMQP message brokers, like RabbitMQ.

As the [RabbitMQ’s official web page](https://www.rabbitmq.com/) explains:

> RabbitMQ is a message broker: it accepts and forwards messages. You can think about it as a post office: when you put the mail that you want posting in a post box, you can be sure that the letter carrier will eventually deliver the mail to your recipient. In this analogy, RabbitMQ is a post box, a post office, and a letter carrier.

To be more precise, the process is as follows: one client called the _producer_ sends a message to an _exchange_. Depending on rules defined by exchange type and routing key provided in the message, exchanges then distribute message copies to _queues_ — essentially large message buffers. The message is finally consumed by a _subscriber_.

If you are interested in more theoretical explanations and some practical examples, you can have a look at the tutorials on the [official web page](https://www.rabbitmq.com/tutorials/tutorial-one-spring-amqp.html).

Before we move on to the next topic, I think it will be very useful to review some of the components of AMQP.


## What are AMQP entities?  

A message is a piece of information that is transmitted from the publisher to the queue and then subscribed to by the consumer. Each message has a set of headers that define its parameters.

A queue is a buffer that can store messages to be consumed later. Its properties can be changed during the creation process. A routing key is used to link queues to an exchange.

A binding is a relation between a queue and an exchange made up of a set of rules that the exchange uses to route messages to queues.

Messages are routed to a queue based on the exchange type and bindings between the exchange and the queue. To receive messages, a queue must be tied to at least one exchange. A routing key is used to send messages to an exchange. After that, the exchange distributes message copies to queues.

AMQP brokers implement four basic exchange types:

- Direct – Routes messages to a queue by matching a complete routing key.
- Fanout – Routes messages to all the queues bound to it.
- Topic – Routes messages to multiple queues by matching a routing key to a pattern
- Headers – Routes messages based on message headers.

I tried to represent these exchange types with the following chart to make it easier to understand:

<figure>
  <img src="https://i.imgur.com/iRvOcHZ.png" alt="Trulli" style="width:100%">
  <figcaption><center>Four basic exchange types implemented by AMQP brokers
</center></figcaption>
</figure>

If you want to have a deeper understanding of these exchange types, bindings, routing keys and how or when you should use them, you can have a look at [this nice blog here](https://hevodata.com/learn/rabbitmq-exchange-type/).


## Setting up the RabbitMQ Broker  

Let’s start by setting up a RabbitMQ server to handle receiving and sending messages. There are several ways of doing that but for our tutorial ,we will use Docker Compose to quickly lunch a RabbitMQ server (you must have a Docker running locally for this solution to work).

First, create a new project with Spring Initializr, adding Spring AMQP as a dependency:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
```

Spring AMQP is an implementation that provides abstractions for AMQP entities, connection management, message publishing, and message consumption.

Then, create a **docker-compose.yml** file in the root of the project and paste the following code there:

```yaml
rabbitmq:
  image: rabbitmq:management
  ports:
    - "5672:5672"
    - "15672:15672"
```

Here, we expose port 5672 so that our application can connect to RabbitMQ. And, we expose port 15672 so that we can see what our RabbitMQ broker is doing via either the management UI: http://localhost:15672 or the HTTP API: http://localhost:15672/api/index.html.

At the moment, leave this file here. We will need it in a couple of minutes.


## Setting up exchange configurations  

We are going to set up configurations for two exchange types: _fanout_ and _topic_.

If you remember, fanout exchange broadcast the same message to all bound queues, while topic exchange use a routing key for passing messages to a particular bound queue or queues.

Let’s create an **ExchangeConfig** class which will contain the following configuration:

```java
@Configuration
public class ExchangeConfig {
    public static final String FANOUT_EXCHANGE_NAME = "fanout.exchange";
    public static final String TOPIC_EXCHANGE_NAME = "topic.exchange";

    public static final String FANOUT_QUEUE_1_NAME = "fanout.queue1";
    public static final String FANOUT_QUEUE_2_NAME = "fanout.queue2";

    public static final String TOPIC_QUEUE_1_NAME = "topic.queue1";
    public static final String TOPIC_QUEUE_2_NAME = "topic.queue2";

    @Bean
    public Declarables fanoutBindings() {
        Queue fanoutQueue1 = new Queue(FANOUT_QUEUE_1_NAME, false);
        Queue fanoutQueue2 = new Queue(FANOUT_QUEUE_2_NAME, false);

        FanoutExchange fanoutExchange = new FanoutExchange(FANOUT_EXCHANGE_NAME, false, false);

        return new Declarables(
                fanoutQueue1,
                fanoutQueue2,
                fanoutExchange,
                BindingBuilder
                        .bind(fanoutQueue1)
                        .to(fanoutExchange),
                BindingBuilder
                        .bind(fanoutQueue2)
                        .to(fanoutExchange)
        );
    }

    @Bean
    public Declarables topicBindings() {
        Queue topicQueue1 = new Queue(TOPIC_QUEUE_1_NAME, false);
        Queue topicQueue2 = new Queue(TOPIC_QUEUE_2_NAME, false);

        TopicExchange topicExchange = new TopicExchange(TOPIC_EXCHANGE_NAME, false, false);

        return new Declarables(
            topicQueue1,
            topicQueue2,
            topicExchange,
            BindingBuilder
                    .bind(topicQueue1)
                    .to(topicExchange)
                    .with("*.legal.*"),
            BindingBuilder
                    .bind(topicQueue2)
                    .to(topicExchange)
                    .with("#.error")
        );
    }
    
}
```

Declarables object is a very comfortable utility provided by Spring AMQP allowing us to aggregate all the declarations of queues, exchanges, and bindings.

We put up one fanout exchange with two queues tied to it in the code above. When we send a message to this exchange, we expect it to be received by both queues. As you may have noticed, any routing key contained with the message is ignored in this type of exchange.

A topic exchange was also declared, with two queues with different binding patterns. The message will be placed in the queue when the routing key matches the pattern.

“*” is used to match a word in a certain position in the binding patterns, whereas “#” is used to match zero or more words. It means that topicQueue1 will receive messages with three-word routing keys, “legal” as the middle word, while topicQueue2 will get messages with routing keys ending in the word error.


## Setting up a Producer  

Next, let’s create a new class **Producer** and paste the following snippet:

```java
@Component
public class Producer {
    public static final String BINDING_PATTERN_LEGAL = "company.legal.documents";
    public static final String BINDING_PATTERN_ERROR = "company.documents.report.error";

    @Bean
    public ApplicationRunner runner(RabbitTemplate rabbitTemplate) {
        String message = "A sample message";
        return args -> {
            rabbitTemplate.convertAndSend(
                    ExchangeConfig.FANOUT_EXCHANGE_NAME,
                    "",
                    message
            );
            rabbitTemplate.convertAndSend(
                    ExchangeConfig.TOPIC_EXCHANGE_NAME,
                    BINDING_PATTERN_LEGAL,
                    message
            );
            rabbitTemplate.convertAndSend(
                    ExchangeConfig.TOPIC_EXCHANGE_NAME,
                    BINDING_PATTERN_ERROR,
                    message
            );
        };
    }
}
```

To send our sample message, we’ll are using the convertAndSend() method of RabbitTemplate, which will be immediately injected once the application starts.

The routing key is just an empty string when sending a message to the fanout exchange because it is disregarded, and the message is forwarded to all bound queues.

When submitting a message to the topic exchange, we include the routing keys, which determine which queues the message will be delivered to.


## Configuring consumers  

Create a new class **Consumer** and set up four consumers for picking up the produced messages — one for each queue:

```java
@Component
public class Consumer {

    @RabbitListener(queues = ExchangeConfig.FANOUT_QUEUE_1_NAME)
    public void consumeMessageFromFanoutQueue1(String message) {
        System.out.println(
                "Received fanout queue 1 message: " + message
        );
    }

    @RabbitListener(queues = ExchangeConfig.FANOUT_QUEUE_2_NAME)
    public void consumeMessageFromFanoutQueue2(String message) {
        System.out.println(
                "Received fanout queue 2 message: " + message
        );
    }

    @RabbitListener(queues = ExchangeConfig.TOPIC_QUEUE_1_NAME)
    public void consumeMessageFromTopicQueue1(String message) {
        System.out.println(
                "Received topic: " + 
                        Producer.BINDING_PATTERN_LEGAL +
                        " queue 1 message: " + message
        );
    }

    @RabbitListener(queues = ExchangeConfig.TOPIC_QUEUE_2_NAME)
    public void consumeMessageFromTopicQueue2(String message) {
        System.out.println(
                "Received topic: " +
                        Producer.BINDING_PATTERN_ERROR +
                        " queue 2 message: " + message
        );
    }
    
}
```

The **@RabbitListener** annotation is used to configure consumers. The name of the queue is supplied to it as a parameter. Consumers are completely unaware of exchanges or routing keys.


## Testing out application  

Our Spring Boot application will automatically initialize the application with a connection to RabbitMQ and set up all queues, exchanges, and bindings.

Start Docker and then run docker-compose up command in the root of the project where the docker-compose.yml file resides. After the image is successfully pulled , start the application.

The output will look like this:

<figure>
  <img src="https://i.imgur.com/Ba3yGp7.png" alt="Trulli" style="width:100%">
  <figcaption><center>Successful output after running our app
</center></figcaption>
</figure>

Of course, the order of the messages is not guaranteed.

<center>***</center>  

In this brief tutorial, we covered fanout and topic exchanges with Spring AMQP and RabbitMQ.

If you have missed anything, all code can be found on my [GitHub repository](https://github.com/anitalakhadze/rabbitmq-exchange-demo).

Please, let me know if you have any questions, comments, or suggestions for the upcoming blogs in this series.

Stay tuned and don’t miss the following tutorials!
