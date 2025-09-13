---
layout: post
title: Part 3 - HOW TO
subtitle: Send emails from a Spring Boot application
gh-repo: anitalakhadze/mail-sender-demo-app
gh-badge: [star, fork, follow]
tags: [Mail, Spring Boot, Java Mail API, Maven, Java]
comments: true
author: Ani Talakhadze
summary: This tutorial shows how to send emails from a Spring Boot application using JavaMailSender, covering project setup, property configuration, service creation, and testing. With clear examples and practical advice, it guides you through building a simple, reliable email-sending feature for your Java projects.
---

Isn’t it the right time to demystify the quite easy process of sending emails from a Spring Boot application? It is a powerful tool for email marketing or mail notifications or any other purpose you may think of. Let’s not waste any time and get right to the point.

The link to the source code repository will be added at the end of this tutorial.


## Setting up a new Spring Boot project  

Create a new project with Spring Initializr. I will be using Java 17 and Maven, but you can choose whichever setup configuration works for you.

<figure>
  <img src="https://i.imgur.com/8TlOOJT.png" alt="Trulli" style="width:100%">
  <figcaption><center>Creating a new Spring Boot Maven project with Spring Initializr
</center></figcaption>
</figure>

Add Java Mail Sender and Lombok dependencies to the project. These are enough for demonstration purposes, as we are not going to build anything really complex.

<figure>
  <img src="https://i.imgur.com/3P8Xy3w.png" alt="Trulli" style="width:100%">
  <figcaption><center>Adding Java Mail Sender and Lombok dependencies to the project
</center></figcaption>
</figure>


## Configuring Mail Properties  

I won’t go into great details here as I have dedicated [my previous blog](https://blog.devgenius.io/part-2-how-to-configure-properties-in-spring-boot-783c54a39304) to providing a step-by-step guide for configuring properties in Spring Boot. If you have already read that article, you can skip much of this section.

First of all, let’s create a separate properties file called mail.properties in /src/main/resources.Add the following configuration to the file (don’t forget to insert valid information where needed):

```properties
mail.transport.protocol=smtp
mail.properties.mail.smtp.auth=true
mail.properties.smtp-starttls-enable=true
mail.properties.mail.smtp.ssl.trust=smtp.gmail.com

# insert valid information instead of these values
mail.host=mail.host.domain
mail.port=port
mail.username=username@domain
mail.password=password
```

Next, register this properties file in your application. Create a new Java class MailProperties in /src/main/property or any of its subfolders, and place the following code inside:

```java
@Data
@Lazy
@Configuration
@PropertySource("classpath:mail.properties")
@ConfigurationProperties(prefix = "mail")
public class MailProperties {

    @Value("${mail.host}")
    private String host;

    @Value("${mail.port}")
    private Integer port;

    @Value("${mail.username}")
    private String username;

    @Value("${mail.password}")
    private String password;

    @Value("${mail.transport.protocol}")
    private String transportProtocol;

    @Value("${mail.properties.mail.smtp.auth}")
    private String smtpAuth;

    @Value("${mail.properties.smtp-starttls-enable}")
    private String enableSmtpStartTls;

    @Value("${mail.properties.mail.smtp.ssl.trust}")
    private String smtpSslTrust;
    
}
```

Finally, create a MailSenderConfiguration class in/src/main/config, which will use all those properties defined above to set Gmail SMTP configurations like host, port number, username, and password:

```java
@Configuration
@AllArgsConstructor
public class MailSenderConfiguration {
    private final MailProperties mailProperties;

    @Bean
    public JavaMailSender emailSender() {
        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();

        mailSender.setHost(mailProperties.getHost());
        mailSender.setPort(mailProperties.getPort());
        mailSender.setUsername(mailProperties.getUsername());
        mailSender.setPassword(mailProperties.getPassword());

        Properties javaMailProperties = mailSender.getJavaMailProperties();
        javaMailProperties.put("mail.smtp.auth", mailProperties.getSmtpAuth());
        javaMailProperties.put("mail.transport.protocol", mailProperties.getTransportProtocol());
        javaMailProperties.put("mail.smtp.starttls.enable", mailProperties.getEnableSmtpStartTls());
        javaMailProperties.put("mail.smtp.ssl.trust", mailProperties.getSmtpSslTrust());
        javaMailProperties.put("mail.debug", "true");

        return mailSender;
    }

}
```

The mail.debug = true property above will ensure that we will see the output in the console while trying to send the message at the end of this tutorial.


## Creating a Mail Object  

Before we continue with creating a mail service, let’s first define a Mail object with simple fields to help us configure the outgoing messages according to our needs:

```java
@Data
public class Mail {
    private String mailFrom;
    private String mailTo;
    private String mailCc;
    private String mailBcc;
    private String mailSubject;
    private String mailContent;
    private String contenType;
    private List<Object> attachments;
}
```


## Creating a Mail Service  

After completing the configuration of mail properties, let’s create a new package service, and inside, create an interface called MailService with sendEmail() method:

```java
public interface MailService {

    void sendEmail(Mail mail);

}
```

Next, go on and create a MailServiceImpl class and annotate it with @Service. Annotate the method with @Async as we want our emails to be sent in a separate thread and not impede the running process of the application.

```java
@Service
@AllArgsConstructor
public class MailServiceImpl implements MailService {
    private final JavaMailSender mailSender;

    @Async
    @Override
    public void sendEmail(Mail mail) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");
            helper.setSubject(mail.getMailSubject());
            helper.setFrom(mail.getMailFrom());
            helper.setTo(mail.getMailTo());
            helper.setText(mail.getMailContent(), true);
            mailSender.send(mimeMessage);
        } catch (MessagingException e) {
            throw new RuntimeException(e.getMessage());
        }
    }
}
``` 

At the end of the method, a populated Spring MimeMessage object will be returned along with attachments and sent via JavaMailSender.send() method.


## Testing the application  

Finally, the time has come to test our application and send emails. Modify the content of the main method of the application like the following:

```java
@SpringBootApplication
public class MailSenderDemoAppApplication {

    public static void main(String[] args) {
        Mail mail = new Mail();
        mail.setMailFrom("hello@anita.com");
        mail.setMailTo("medium.readers@gmail.com");
        mail.setMailSubject("Thanks!");
        mail.setMailContent("Thank you for reading my blogs!");

        ApplicationContext ctx = SpringApplication.run(MailSenderDemoAppApplication.class, args);
        MailService mailService = (MailService) ctx.getBean("mailServiceImpl");
        mailService.sendEmail(mail);
    }

}
```

After you start the application, everything should run smoothly. However, if you are experiencing troubles while sending mail with an error like “Authentication Failed”:

<figure>
  <img src="https://i.imgur.com/PeoqwUN.png" alt="Trulli" style="width:100%">
  <figcaption><center>Getting MailAuthenticationException
</center></figcaption>
</figure>

you may want to check your Gmail account security settings and turn on the less secure app access. This is not approved for general usage, of course, we are doing this only for demonstration purposes:

<figure>
  <img src="https://i.imgur.com/srkmNNB.png" alt="Trulli" style="width:100%">
  <figcaption><center>Gmail account setting for enabling less secure app access
</center></figcaption>
</figure>

After having modified that setting, you can see that the mail was successfully sent from the console output:

<figure>
  <img src="https://i.imgur.com/AO3Lc3I.png" alt="Trulli" style="width:100%">
  <figcaption><center>Console output after successfully sending the mail
</center></figcaption>
</figure>

That’s it! Really easy and simple, I hope!

<center>***</center>

We have successfully created a Spring Boot project for sending emails. If you have missed anything, all code can be found on [my GitHub repository](https://github.com/anitalakhadze/mail-sender-demo-app).

Please, let me know if you have any questions, comments, or suggestions for the upcoming blogs in this series.

Stay tuned and don’t miss the following tutorials!