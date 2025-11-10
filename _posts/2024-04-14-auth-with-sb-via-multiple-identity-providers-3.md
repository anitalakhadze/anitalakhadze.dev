---
layout: post
title: "[Part 3] — Authentication with Multiple Identity Providers"
author: Ani Talakhadze
summary: Implementing Authentication with Spring Boot Security 6, OAuth2, and Angular 17 via Multiple Identity Providers - Getting Authorization Credentials for Google, GitHub and Twitter
---

<figure>
    <img src="https://i.imgur.com/GSfq3xf.png" alt="Spring Boot Security 6, OAuth 2 and Angular 17" style="width:100%">
</figure>

The third part of our series, though not centered on coding per se, holds considerable importance.

In general, any application that uses OAuth 2.0 to access social login provider APIs, must have authorization credentials that identify the application to the provider’s OAuth 2.0 server.

Many developers, myself included, have encountered the frustration of acquiring or setting up these credentials. In this segment, I’ll walk you through the process on the example of Google, GitHub and Twitter, so that we can use them in our application later.

I recommend revisiting the first and second parts of this series for a more comprehensive grasp of our current task.

# Google Authorization Credentials

Navigate to [Google API Console](https://console.cloud.google.com/) and create a new project. Carefully choose the google account with which you will be associating your project.

<figure>
    <img src="https://i.imgur.com/SPBQjL9.png" alt="Google API Console — List of Projects" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — List of Projects<br>
    </figcaption>
</figure>

Follow the instructions on the screen and choose a memorable name:

<figure>
    <img src="https://i.imgur.com/XXeZRay.png" alt="Google API Console — New Project Creation" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — New Project Creation
<br>
    </figcaption>
</figure>

You will be notified about the successful creation in the notifications pane and you can navigate to the newly created project from there:

<figure>
    <img src="https://i.imgur.com/EFcEvd1.png" alt="Google API Console — Successful Creation of a Project" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — Successful Creation of a Project
<br>
    </figcaption>
</figure>

Once navigated, you will see that the new project has been preselected in the projects list and you can monitor all the different metrics right from the dashboard:

<figure>
    <img src="https://i.imgur.com/x8GHtmh.png" alt="Google API Console — Project Dashboard" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — Project Dashboard<br>
    </figcaption>
</figure>

Navigate to the `credentials` menu:

<figure>
    <img src="https://i.imgur.com/TYIOHJp.png" alt="Google API Console — Navigating to Credentials Menu" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — Navigating to Credentials Menu<br>
    </figcaption>
</figure>

Create new OAuth client ID credentials:

<figure>
    <img src="https://i.imgur.com/TYIOHJp.png" alt="Google API Console — New Credentials Creation" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — New Credentials Creation<br>
    </figcaption>
</figure>

You will be prompted to configure the consent screen first, before proceeding to the next steps:

<figure>
    <img src="https://i.imgur.com/A4ru9yp.png" alt="Google API Console — Consent Screen Configuration Prompt" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — Consent Screen Configuration Prompt<br>
    </figcaption>
</figure>

Select `External` as the user type and remember, from the the information that’s provided, that unless you add a user to the list of test users, they won’t be able to authenticate (because the app is in testing mode and we are not planning to push it to production):

<figure>
    <img src="https://i.imgur.com/PgMgNV1.png" alt="Google API Console — User Type Specification" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — User Type Specification<br>
    </figcaption>
</figure>

Fill in the information about your app. Choose the name carefully as it will be presented to the users:

<figure>
    <img src="https://i.imgur.com/W7G2Yn3.png" alt="Google API Console — Consent Screen Configuration [part 1]" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — Consent Screen Configuration [part 1]<br>
    </figcaption>
</figure>

<figure>
    <img src="https://i.imgur.com/tWdhqpn.png" alt="Google API Console — Consent Screen Configuration [part 2]" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — Consent Screen Configuration [part 2]<br>
    </figcaption>
</figure>

Save and continue to choosing the scopes for your app. Select only user info and user profile scopes as we won’t be needing more for our application:

<figure>
    <img src="https://i.imgur.com/h4MD9Pa.png" alt="Google API Console — Scope Configuration" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — Scope Configuration<br>
    </figcaption>
</figure>

Save and continue to next section — `test users`. Here add any email that you will be using for authenticating with our application. Then save and continue:

<figure>
    <img src="https://i.imgur.com/0JR9vva.png" alt="Google API Console — Adding Test Users" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — Adding Test Users<br>
    </figcaption>
</figure>

Last, you will be displayed a summary of the configuration and you can get back to the credentials menu. Now that we have configured the consent screen, you will directly be displayed the client ID creation form:

<figure>
    <img src="https://i.imgur.com/gFQl4nV.png" alt="Google API Console — OAuth Client ID Creation" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — OAuth Client ID Creation<br>
    </figcaption>
</figure>

Choose `web application` in the application type:

<figure>
    <img src="https://i.imgur.com/2KNZXSk.png" alt="Choosing application type" style="width:100%">
    <figcaption style="text-align: center;">
        Choosing application type<br>
    </figcaption>
</figure>

Provide the app details, including *authorized JavaScript origins* (the address where our Angular application will be hosted) and *authorized redirect URIs* (the URI where users will be redirected post-authentication, typically to our backend app for user authentication and information handling):

<figure>
    <img src="https://i.imgur.com/nJT6Saf.png" alt="Google API Console — OAuth Client ID Configuration" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — OAuth Client ID Configuration<br>
    </figcaption>
</figure>

After creating the credentials, you’ll encounter a pop-up displaying the necessary information: the client ID and client secret. Feel free to copy this information or retrieve it later as needed; it’ll be accessible at any time:

<figure>
    <img src="https://i.imgur.com/ttDSpN3.png" alt="Google API Console — OAuth Client Credentials" style="width:100%">
    <figcaption style="text-align: center;">
        Google API Console — OAuth Client Credentials<br>
    </figcaption>
</figure>

Next, add the following to your **application.properties**. Don’t forget to replace CLIENT_ID and CLIENT_SECRET with the credentials that you generated above.

```
# Google OAuth2 Configuration
spring.security.oauth2.client.registration.google.clientId=CLIENT_ID
spring.security.oauth2.client.registration.google.clientSecret=CLIENT_SECRET
spring.security.oauth2.client.registration.google.redirectUri={baseUrl}/oauth2/callback/{registrationId}
spring.security.oauth2.client.registration.google.scope=email, profile
```

This should suffice to progress with our application. However, if you require further details or wish to delve deeper, you can explore Google’s documentation [here](https://developers.google.com/identity/protocols/oauth2/javascript-implicit-flow).


# GitHub Authorization Credentials

Next, we’ll transition to GitHub. You can create and register an OAuth app under your personal account or within any organization where you have administrative access.

Navigate to your GitHub account settings and then all the way down to the developer settings:

<figure>
    <img src="https://i.imgur.com/av3u5Fp.png" alt="GitHub Account Settings" style="width:100%">
    <figcaption style="text-align: center;">
        GitHub Account Settingss<br>
    </figcaption>
</figure>

<figure>
    <img src="https://i.imgur.com/odfeXaz.png" alt="GitHub Account Developer Settings" style="width:100%">
    <figcaption style="text-align: center;">
        GitHub Account Developer Settings<br>
    </figcaption>
</figure>

Select OAuth apps and choose `New OAuth App`:

<figure>
    <img src="https://i.imgur.com/0CFdDWm.png" alt="GitHub Developer Settings" style="width:100%">
    <figcaption style="text-align: center;">
        GitHub Developer Settings<br>
    </figcaption>
</figure>

Fill in the information and click `Register application`:

<figure>
    <img src="https://i.imgur.com/gHUJfUS.png" alt="GitHub — Registering New OAuth Application" style="width:100%">
    <figcaption style="text-align: center;">
        GitHub — Registering New OAuth Application<br>
    </figcaption>
</figure>

Once created, you’ll be directed to a summary page where the client ID will already be displayed. However, the client secret will not be shown yet. For generating the secret, you should click **Generate a new client secret**. You will be prompted to verify your access and authenticate.

<figure>
    <img src="https://i.imgur.com/X4659lc.png" alt="GitHub — Client ID Generation" style="width:100%">
    <figcaption style="text-align: center;">
        GitHub — Client ID Generation<br>
    </figcaption>
</figure>

Be sure to copy the client secret once it’s displayed, as you won’t have access to it once you leave the page.

<figure>
    <img src="https://i.imgur.com/i2sicUa.png" alt="GitHub — Client Secret Generation" style="width:100%">
    <figcaption style="text-align: center;">
        GitHub — Client Secret Generation<br>
    </figcaption>
</figure>

Replace the CLIENT_ID and CLIENT_SECRET properties with the credentials generated for GitHub in your **application.properties** file. Additionally, note that scopes need to be configured in different formats for different providers (*missing that is one of the most common sources for errors*).

```
# GitHub OAuth2 Configuration
spring.security.oauth2.client.registration.github.clientId=CLIENT_ID
spring.security.oauth2.client.registration.github.clientSecret=CLIENT_SECRET
spring.security.oauth2.client.registration.github.redirectUri={baseUrl}/oauth2/callback/{registrationId}
spring.security.oauth2.client.registration.github.scope=user:email, read:user
```

Once more, if you require additional information, referring to the [official documentation](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app) would be a good idea.


# Twitter Authorization Credentials

For Twitter integration, you’ll need to navigate to the [developer portal](https://developer.twitter.com/en/portal/dashboard), then open the **Projects & Apps** menu. Select the default project or create a new one if projects aren’t visible yet:

<figure>
    <img src="https://i.imgur.com/UJ8hch5.png" alt="Twitter — Projects & Apps" style="width:100%">
    <figcaption style="text-align: center;">
        Twitter — Projects & Apps<br>
    </figcaption>
</figure>

Follow the provided instructions and complete the required information in a similar manner to this:

<figure>
    <img src="https://i.imgur.com/EI1Vstz.png" alt="Twitter — Project Configuration [Part 1]" style="width:100%">
    <figcaption style="text-align: center;">
        Twitter — Project Configuration [Part 1]<br>
    </figcaption>
</figure>

<figure>
    <img src="https://i.imgur.com/Axy1Iq5.png" alt="Twitter — Project Configuration [Part 2]" style="width:100%">
    <figcaption style="text-align: center;">
        Twitter — Project Configuration [Part 2]<br>
    </figcaption>
</figure>

<figure>
    <img src="https://i.imgur.com/LEk8xP6.png" alt="Twitter — Project Configuration [Part 3]" style="width:100%">
    <figcaption style="text-align: center;">
        Twitter — Project Configuration [Part 3]<br>
    </figcaption>
</figure>

<figure>
    <img src="https://i.imgur.com/RcVZpXN.png" alt="Twitter — Project Configuration [Part 4]" style="width:100%">
    <figcaption style="text-align: center;">
        Twitter — Project Configuration [Part 4]<br>
    </figcaption>
</figure>

At the final step, your credentials will be generated. Ensure to copy them attentively this time as Twitter, like GitHub, won’t display the same credentials again. You’d need to regenerate them if they’re lost:

<figure>
    <img src="https://i.imgur.com/JKILp6s.png" alt="Twitter — App Credentials" style="width:100%">
    <figcaption style="text-align: center;">
        Twitter — App Credentials<br>
    </figcaption>
</figure>

Now the app we created will be visible in the projects list in side bar. Select it and then click **Set up** next to the user authentication settings:

<figure>
    <img src="https://i.imgur.com/aQwLA67.png" alt="Setting up user authentication" style="width:100%">
    <figcaption style="text-align: center;">
        Setting up user authentication<br>
    </figcaption>
</figure>

Configure the settings like the following:

<figure>
    <img src="https://i.imgur.com/bUxMMTv.png" alt="Twitter — User Authentication Settings [Part 1]" style="width:100%">
    <figcaption style="text-align: center;">
        Twitter — User Authentication Settings [Part 1]<br>
    </figcaption>
</figure>

<figure>
    <img src="https://i.imgur.com/GnVnqKk.png" alt="Twitter — User Authentication Settings [Part 2]" style="width:100%">
    <figcaption style="text-align: center;">
        Twitter — User Authentication Settings [Part 2]<br>
    </figcaption>
</figure>

Once saved, get back to your app’s dashboard, go to **keys and tokens** and copy the client ID and client secret:

<figure>
    <img src="https://i.imgur.com/iYdwEqN.png" alt="Twitter — Client ID and Client Secret Generation" style="width:100%">
    <figcaption style="text-align: center;">
        Twitter — Client ID and Client Secret Generation<br>
    </figcaption>
</figure>

Add the following to the **application.properties**, don’t forget to replace the placeholders with the actual values you copied above:

```
# Twitter OAuth2 Configuration
spring.security.oauth2.client.registration.twitter.client-id=CLIENT_ID
spring.security.oauth2.client.registration.twitter.client-secret=CLIENT_SECRET
spring.security.oauth2.client.registration.twitter.redirect-uri={baseUrl}/oauth2/callback/{registrationId}
spring.security.oauth2.client.registration.twitter.scope=read:users
```

You can visit the [official docs](https://developer.twitter.com/en/docs/authentication/oauth-2-0) for any additional information or follow-up questions.


# Facebook & LinkedIn Authorization Credentials

For Facebook, acquiring credentials requires business verification. Similarly, LinkedIn authorization cannot be done under a member’s profile. You may need to inquire about this with your clients. If you’re aware of any alternative solutions, feel free to share them in the comments section.

---

That wraps up this tutorial. I hope it provided valuable insights. Next, we’ll proceed to set up a minimal frontend application and test our configurations in action.

As usual, the tutorial code can be found on [my GitHub repository](https://github.com/anitalakhadze/multiple-auth-api) under the branch `tutorial/part-3` if you wish to explore it in isolation. Alternatively, you can track the application’s progress on the main branch.