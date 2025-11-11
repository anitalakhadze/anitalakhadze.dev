---
layout: post
title: IntelliJ IDEA Insider - Getting Started
author: Ani Talakhadze
summary: Part 1 — Setup and Configuration
---

![captionless image](https://miro.medium.com/v2/resize:fit:1026/format:webp/1*he1ejkGcyRuyExqrgvbGKw.png)

IntelliJ IDEA, made by JetBrains, is an absolute favorite among developers (pros included), and I’m totally on board. Ever since I started using it, I’ve never needed anything else!

For a lot of people, especially newcomers, mastering an IDE can feel pretty overwhelming _(I’m not fully enlightened myself, not nearly there)_. That’s why I’m starting **IntelliJ Insider** — an experimental series to help beginners discover all the cool features, tips, and tricks IntelliJ IDEA has to offer. If it seems helpful, I’ll keep it going!

Much more advanced topics are to come, but for this very first tutorial, I want to cover a mix of essential features and productivity tips that you can immediately benefit from.

** **_In case you are interested what some of my other favorite tools are,_** [**_check this blog out_**](https://medium.com/@anitalakhadze/10-essential-tools-that-i-use-every-day-2eaead5d094d)**_._**

Installation
------------

Installing IntelliJ IDEA is just as easy as installing any other application. Navigate to the [**official website**](https://www.jetbrains.com/idea/download) and download the installer for your operating system:

![Downloading Intellij IDEA](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*uBpNjmFvieJVWU8VuB6wiQ.png)

On the same page you can find other helpful information, like the recommended system requirements and installation instructions.

![IntelliJ IDEA: system requirements and installation instructions](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*TwRIJPziHfue7tFmXqGjFw.png)

IntelliJ IDEA offers two options: Ultimate and Community Edition. There are quite some [**differences between those two**](https://www.jetbrains.com/products/compare/?product=idea-ce), but if you are just starting, believe me, community version is just fine for everything you may need.

![IntelliJ IDEA Ultimate vs IntelliJ IDEA Community Edition](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*kj9H97xtfPjnjHkqwacTrA.png)

🟢 If you are a student, I would strongly advice to [**create a JetBrains account**](https://www.jetbrains.com/community/education/#students) and activate your license for free. You will get access to Ultimate version and enjoy its benefits.

Opening a Project
-----------------

When you launch IntelliJ IDEA for the first time, you’ll be greeted by the **Welcome Screen**. Here, you have options to create a new project, open an existing project, or clone from a version control system.

![IntelliJ IDEA: welcome screen](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*RYTqOCJUPN3jzjJF.png)

You’ll also be given a chance to configure some initial settings, such as the IDE theme (choose between **Light**, **Dark**, or **Darcula**) and font size (more about this a bit later). You can also import any settings from previous installations if applicable.

For the purposes of our tutorial, let’s select “New Project”. As you will see, there are quite a few options to choose from — like Java or Kotlin projects, or generators — like Spring Boot initializer _(not available in community version, sadly)_ and such. We will select Java and couple of settings to get us started:

![IntelliJ IDEA: starting a new project](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*t6SwAyO1q-PntVeIVcnt_Q.png)

Configuring The Appearance
--------------------------

Once you have created or opened a project, we can move to customizing IDE to fit your taste.

Usually, the very first thing I do when I have to install IntelliJ on a new machine or OS, it is to configure the theme. There are quite a few ways to get there — via the quick settings:

![Configuring a theme from quick settings](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*Z2MaPK8OpG0grROChA_MvQ.png)

Or the complete settings menu:

![Configuring a theme from settings menu](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*a-QuCCwbAQrD_XWxe-4U4w.png)

I experiment a lot to find different themes better suited for my taste. If you are like me, then a good place to start discovering is the “Plugins” section in the settings _(also available on the_ [**_official web page_**](https://plugins.jetbrains.com/)_)_ where you can search themes _(and not only themes)_ inside the marketplace with any keyword:

![Searching for themes in Plugins Marketplace](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*-Y4QXB8nZrQ6GTz8eZaK7A.png)

Some of my favorites are: [**Monokai Pro Theme**](https://plugins.jetbrains.com/plugin/13643-monokai-pro-theme)

![Recommended theme: Monokai Pro](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*g1w2IuyQGzcSFGSNapHqsQ.png)

and [**Rider UI Theme Pack**](https://plugins.jetbrains.com/plugin/13883-rider-ui-theme-pack):

![Recommended theme: Rider UI Theme Pack](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*Z2VnegJPRE6Jv_QG8O2E4A.png)

I change them a lot regularly but I always end up setting white, light themes for my daily work _(please, don’t judge me_ 😅 _— setting a white theme helps me focus on the code much better than the dark one)_:

![Setting a theme](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*7fA8M-1REAAi7KAa82v6Mg.png)

To customize your environment much further, with the right click on the header a menu opens and you can even set a custom icon to the project _(especially helpful if you have multiple ones open at the same time)_, change project color, control gradient and so on _(not to mention the vast possibilities the “Customize Toolbar” offers, which we will explore in the following tutorials)_:

![Changing project header color](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*Xz3t3Ea7SbAB0iJ0tywOWA.png)

You can also adjust the **editor font size**, **style**, and other visual elements to make the IDE more readable and comfortable to work in.

One other thing I always change is the opened tabs placement rules and limit policy. I prefer to have multiple rows open and control the process myself rather than automatically closing the unused ones.

![Allow tabs to be opened in multiple rows](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*PQzmir_M-rU1VWbq3S60dg.png)

Usually, I increase the tab limit as well:

![Increase max open tabs limit](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*MoJU58Cie6UouIgQj4XkQQ.png)

To have wider field of view and switch between them easily between:

![Multiple rows of tabs opened](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*y_czBL1HuzT1KAsmfiio0w.png)

Configuring Keymaps and Shortcuts
---------------------------------

IntelliJ IDEA is highly customizable when it comes to keyboard shortcuts. You can choose from predefined keymaps like **IntelliJ Default**, **Eclipse**, or **Visual Studio Code**, depending on what you are familiar with _(mine is macOS)_.

![Modifying keymap system](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*e3tYTHY4y0pOvOfqoU_oMA.png)

You can also create custom shortcuts for the actions you use most frequently by searching for them in the keymap settings and assigning your preferred key combinations, for example, navigating back or forward:

![Customizing keymap shortcuts](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*BAB70TqMQAs8_t5Twz7t3g.png)

Getting used to working with shorcuts is something that comes with practice through time, so don’t worry if you fail to remember them. You will get there soon enough.

**Basic Plugin Setup**
----------------------

Plugins extend the functionality of IntelliJ IDEA. You can browse essential plugins like **Git**, **Lombok…** _(or the carefree ones, like this adorable Nyan Progress Bar)_**.**

![Installing plugins from marketplace](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*SRxiF_KGwyeznmvPbYqAFA.png)

To install a plugin, simply search for it, click **Install**, and restart IntelliJ IDEA if prompted. You can manage or disable installed plugins from the same settings menu, “Installed” section.

**Configuring Version Control Integration**
-------------------------------------------

IntelliJ IDEA comes with built-in support for version control systems _(you will also notice GitHub and GitLab settings below)_.

![Version control system settings](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*oc6LuLFGy218ySIqDDNETA.png)

Once you connect with your GitHub account, you can very conveniently share the project in seconds on your profile:

![Sharing project on GitHub](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*c3YaC0Ad3VPoi5Q5lXa32Q.png)

For existing repositories, you can clone them directly from the welcome screen or from VCS menu.

![Opening a project from VCS](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*AGY18Fs4m2cGvMROaOpbDg.png)

### #helpful-tip 🐣

You can tweak memory settings for better performance. Just go to **Help > Edit Custom VM Options** and increase the heap size if needed — especially if your IDE keeps warning you about low memory.

*   The first instruction below is setting maximum heap size to 4096MB (4GB) _(But don’t do it if you are not sure if your machine can handle it. Setting it too high may cause system memory issues)_.
*   The second instruction disables Metal API for Java 2D rendering on macOS _(I needed it as I was experiencing random crashes due to Apple silicon using Metal API causing issues in Swing-based applications, like IntelliJ IDEA)_.

![Increasing heap size for the application](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*GO4LWWda2KL8M7mgVgZHvQ.png)

That’s a wrap for the first blog! Hope you had fun and picked up something new.