---
layout: post
title: Part 5 - HOW TO
subtitle: Work with PDF files with Apache PDFBox in Java
gh-repo: anitalakhadze/apache-pdfbox-demo
gh-badge: [star, fork, follow]
tags: [Apache, PDF, PDFBox, Spring Boot, Maven]
comments: true
author: Ani Talakhadze
summary: This tutorial introduces Apache PDFBox, a Java library for creating and reading PDF files. It walks through setting up a project, writing text and images to PDFs, extracting text, and adding document metadata—all with clear code examples—making it easy to handle common PDF tasks programmatically.
---

Who doesn’t enjoy applying well-thought-out solutions? Any of us would want to write beautiful code that we could be proud of. However, essential and common tasks for business don’t always have elegant answers. Anyone who has worked with PDF files will definitely agree with me.

Fortunately, Apache PDFBox, a nice Apache library, can be helpful to us in this situation. I’ll demonstrate how to use this library to create and read PDF files in Java in today’s tutorial so you can decide whether the excitement is fair or not.

The link to the source code repository will be added at the end of this tutorial.

## Setting up the project  
Create a basic Java project in your preferred IDE to get things started. For this tutorial, I’ll be managing my dependencies with Maven, but Gradle is also an option.

<figure>
  <img src="https://i.imgur.com/wWg1OMl.png" alt="Trulli" style="width:100%">
  <figcaption><center>Setting up a Maven project in IntelliJ IDEA.
</center></figcaption>
</figure>

And add the Apache PDFBox dependency to the pom.xml file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.example</groupId>
    <artifactId>apache-pdfbox-demo</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.apache.pdfbox</groupId>
            <artifactId>pdfbox</artifactId>
            <version>2.0.26</version>
        </dependency>
    </dependencies>

</project>
```

## Text-to-PDF writing example  

I’ll start by demonstrating how to make a PDF file and add some text to it. From this point on, import statements are implied but not included in the snippets.

A new PDDocument should be created first, after which a new page should be added to the document. The PDPageContentStream can write text to a PDF page. Between the beginText() and endText() methods, each line of text will be written to the page.

```java
public class WriteText {

    public static void main(String[] args) {
        try (PDDocument doc = new PDDocument()) {
            PDPage pdPage = new PDPage();
            doc.addPage(pdPage);

            try (PDPageContentStream contentStream = new PDPageContentStream(doc, pdPage)) {
                contentStream.beginText();

                contentStream.setFont(PDType1Font.TIMES_ROMAN, 12);
                contentStream.setLeading(14.5f);
                contentStream.newLineAtOffset(25, 500);

                for (String line : getPdfContentLines()) {
                    contentStream.showText(line);
                    contentStream.newLine();
                }

                contentStream.endText();
            }

            doc.save("src/main/resources/lorem-ipsum.pdf");
        } catch (IOException ioException) {
            System.out.println("Handling IOException...");
        }
    }

    static List<String> getPdfContentLines() {
        return Arrays.asList(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                "Ut enim ad minim veniam, quis nostrud exercitation ullamco",
                "laboris nisi ut aliquip ex ea commodo consequat.",
                "Duis aute irure dolor in reprehenderit in voluptate velit esse",
                "cillum dolore eu fugiat nulla pariatur.",
                "Excepteur sint occaecat cupidatat non proident",
                "sunt in culpa qui officia deserunt mollit anim id est laborum."
        );
    }

}
```

When you run this simple program, the PDF it created will appear right away in the resources folder:

<figure>
  <img src="https://i.imgur.com/zdc3Pnw.png" alt="Trulli" style="width:100%">
  <figcaption><center>WriteText program execution result
</center></figcaption>
</figure>  

## PDF-to-Text reading example  

In addition to creating PDF files, we can also read and process them according to our needs.

```java
public class ReadText {

    public static void main(String[] args) {
        File loremIpsumFile = new File("src/main/resources/lorem-ipsum.pdf");
        
        try (PDDocument doc = PDDocument.load(loremIpsumFile)) {
            PDFTextStripper pdfTextStripper = new PDFTextStripper();
            String text = pdfTextStripper.getText(doc);

            System.out.println("Text size: " + text.length() + " characters.\n");
            System.out.println(text);
        } catch (IOException ioException) {
            System.out.println("Handling IOException...");
        }
    }
    
}
```

Here we loaded the PDF document we created in the first section and logged the size of the text and extracted its content via the PDFTextStripper.

The program shows the following results after the execution:

<figure>
  <img src="https://i.imgur.com/4kH5COg.png" alt="Trulli" style="width:100%">
  <figcaption><center>ReadText program execution result
</center></figcaption>
</figure>

## Image-to-PDF example  

Now we will try to create an image in a PDF document:

```java
public class CreateImage {

    public static void main(String[] args) {
        try (PDDocument doc = new PDDocument()) {
            PDPage pdPage = new PDPage();
            doc.addPage(pdPage);

            String imgFileName = "src/main/resources/deep_field.jpg";
            PDImageXObject pdImage = PDImageXObject.createFromFile(imgFileName, doc);

            int iw = pdImage.getWidth();
            int ih = pdImage.getHeight();
            float offset = 20f;

            try (PDPageContentStream contentStream = new PDPageContentStream(doc, pdPage)){
                contentStream.drawImage(pdImage, offset, offset, iw, ih);
            }

            doc.save("src/main/resources/deep_field.pdf");
        } catch (IOException ioException) {
            System.out.println("Handling IOException...");
        }
    }

}
```

In this example, we loaded an image from a directory, created a new PDF document, and added the image into the page. Then we got the width and height of the image and drew it into the page with PDPageContentStream’s drawImage().

Successful execution of the program will give you a similar result:

<figure>
  <img src="https://i.imgur.com/bAYD4VM.png" alt="Trulli" style="width:100%">
  <figcaption><center>CreateImage program execution result
</center></figcaption>
</figure>

## Retrieve document information  

The author of the document and the date it was created are just two examples of information that PDF documents might provide. Using the PDDocumentInformation object, data can be set and retrieved:

```java
public class DocumentInformation {

    public static void main(String[] args) {
        try (PDDocument doc = new PDDocument()) {
            PDPage pdPage = new PDPage();
            doc.addPage(pdPage);

            PDDocumentInformation pdi = doc.getDocumentInformation();

            pdi.setAuthor("Ani Talakhadze");
            pdi.setTitle("Apache PDFBox Practice");
            pdi.setCreator("Java Code");

            Calendar date = Calendar.getInstance();
            pdi.setCreationDate(date);
            pdi.setModificationDate(date);

            pdi.setKeywords("Apache, PDF");

            doc.save("src/main/resources/doc_inf.pdf");
        } catch (IOException ioException) {
            System.out.println("Handling IOException...");
        }
    }

}
```

The example creates some document information metadata. The information can be seen in the properties of the PDF document in a PDF viewer.

<figure>
  <img src="https://i.imgur.com/Wf3sK3m.png" alt="Trulli" style="width:100%">
  <figcaption><center>Document properties of the doc_inf.pdf
</center></figcaption>
</figure>

<center>* * *</center>

In this short tutorial, we demonstrated simple cases for Apache PDFBox library usage. If interested, you could visit the [official documentation](https://pdfbox.apache.org/) and explore its capabilities.

If you have missed anything, all code can be found on my [GitHub repository](https://github.com/anitalakhadze/apache-pdfbox-demo).

Let me know if you have any questions, comments, or suggestions for the upcoming blogs in this series.

Stay tuned and don’t miss the following tutorials!

