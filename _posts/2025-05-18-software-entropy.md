---
layout: post
title: Software Entropy
author: Ani Talakhadze
summary: Not so long ago I came across the term Software Entropy (aka software rot, code rot, software decay…) and it instantly caught my attention. While entropy is a scientific concept, the context was about software development and the term described the process of "degradation of the use or performance of software over time." Why not get into details?
---

Every developer knows the feeling: you open a piece of code and think, *“Wait, how did it get this bad?”* It wasn’t always this way - something happened over time. That “something” has a name: software entropy. Let's unpack what it is, why it creeps into every project, and what it means for us as developers.

## What does entropy represent in physics?
This one's pretty tough (especially for me, as I'm not an expert in physics, but to define in the simplest (and most-relatable for our blog) way, it measures how disordered or random energy or matter (system, in general) is. The more random and more unpredictable, the higher the entropy.

While being quoted in various ways, the Second Law of Thermodynamics even states that total disorder (or entropy) of the system tends to increase over time, unless energy is used to maintain order (this last part is quite important) - imagine, heat flowing from hot to cold, or things decaying over time.

The term is not only restricted to being used in physics, but computing, information, or what we care about now most - software.

## How is entropy related to computing and information?
In computing, entropy refers to randomness - unpredictable, hard-to-guess data, hence its main adoption in cryptography (and other uses, that require random data) for things like: generating secure passwords or encryption keys, creating more secure communication sessions. In here, the more random something (password, key…) is (so, the higher the entropy is), the harder it is for malicious actors to guess it.

But main thing is that computers are not spontaneous, but deterministic - "doing random" is not what they naturally do. To address that, operating systems gather randomness from hardware sources. For example, the Linux Kernel generates entropy (or random character data) from keyboard timings, mouse movements and such, to make it available to other OS processes when needed.

As for information entropy (concept was introduced by Claude Shannon, an American mathematician), it refers to the average amount of information produced by a random source of data, meaning that the more unpredictable a source is, the higher its entropy, and each symbol produced carries more information. For example, the text "AAAAA" is very predictable (low entropy) and can be easily compressed. But "XNDFS" is random (high entropy), having no pattern, so we can't really shorten it. In here, the lower the entropy is, the better compression is.

## How does entropy apply to software development?
Concept of Software Entropy was introduced by Meir Lehman, a computer scientist, mirroring the concept of entropy in physics and metaphorically applying it to software, to describe the gradual degradation of software systems unless work is done to maintain or reduce it.

A very interesting, related topic is the Laws of Software Evolution, formulated by Lehman and Belady starting in 70-ies with respect to software evolution - "Observing that most software is subject to change in the course of its existence, the authors set out to determine laws that these changes will typically obey, or must obey for the software to survive." Notably, software entropy is also one of the laws in this collection.

## What are the main causes of software entropy?
Many factors can be responsible for software rot, starting from external ones (constantly changing requirements, developer turnover…), ending with internal (indifferent approach, spaghetti code…). Let's try to pay due attention to each factor I managed to identify.

### Changes in the environment (in-house or market)
Even if our code doesn't change, everything around it does (and faster lately). Frameworks deprecate things (i.e., some approaches from Spring Boot 2 are no longer applicable in Spring Boot 3), APIs evolve, deployment environment gets updated. Not only that, but new policies are introduced internally very frequently or teams get reorganized often and the list does not end. Change is the way of life. It's how it has always been. However, without proper adaptation, the factors around have a huge impact on our code: something that once worked suddenly doesn't anymore, and the assumptions that we put in our system, the reliances we put on outer world start to break.

### Onceability
I did not want to neglect this special term (coined by Jonas Söderström, an information architect, in an article). It refers to the phenomenon where a user successfully sets up or uses a digital device or system once, but later finds it impossible to replicate that success because of software updates, lost documentation, or forgotten configurations.
This concept highlights how digital tools can become unusable over time - not because they physically break, but because their operational context changes or critical information becomes inaccessible.

### Quick fixes and workarounds
We all have been here, literally: patch something up quickly to unblock a colleague or a release, promising ourselves "yeap, I will clean it up later". How many times has this "later" come? ZERO.
Imagine such solutions (undocumented, ofc) piling up into a big beautiful minefield. The codebase becomes sensitive even to the tiniest change and no one can really tell which line is an intentional workaround and which is just buggy logic. What starts clean slowly turns messy, buried under all the "just one more thing"s and "just this time"s that seemed harmless at the moment.

### Lack of documentation
This one is like playing a guessing game during a call with colleagues while sharing our screen to collectively try to understand the black magic behind the code. How fun it is, right?
Having no documentation means that everyone in the team (including us) is going to waste time rediscovering things - time that could have been better spent on feature development (or anything more meaningful, for that matter).

### Copy-paste code
It's quick. It works. It also quietly builds up tech debt.
Copying logic instead of reusing it means bugs are spread, fixes are unevenly applied, and behavior starts drifting. Before we know it, we've got several almost-identical versions - and no one's sure which one's right. Good luck finding out!

### Changing requirements without proper adaptation
Business needs evolve, and that's fine. But if the changes keep getting built on top of an architecture that never adapts to them, entropy creeps in. We end up with a system that theoretically works, but everything feels off, and nothing makes sense unless we know the whole history behind the code line.

### Developers leaving without handovers
How many times have you seen someone leave the company, and suddenly every new problem feels like a ticking bomb?
Each of us carries implicit knowledge - the "whys" behind decisions, the context, and those little "aha!" moments that shaped the code. Without a proper handover, that knowledge disappears, and the system starts surprising us in all the wrong ways.

## How do developers experience entropy in their daily work?
This is the most painful one, as probably each of you (including me) has experienced most of (if not all) the obvious signs of entropy:
- **Code gets harder to understand** - What used to be a straightforward method now has five conditionals, three edge-case flags, and a TODO from 2021 saying "this has to be fixed asap".
- **Bugs become more frequent** - Small changes trigger unexpected regressions. Fixing one thing breaks another.
New features take longer to implement - The system becomes change-resistant. What should be a simple addition turns into a full-day exploration (and a few hour-long calls with teammates).
- **Teams hesitate to touch parts of the system** - Some areas develop a reputation: "Don't go in there unless you [really, REALLY] have to." Fear of unintended consequences grows, and with it, the reluctance to refactor or clean up.
- **Tech debt accumulates quietly** - Entropy shows up in the small things - the quick fixes, the postponed refactors, the implicit decisions. Then one day, we're knee-deep in total chaos and wondering how we got there.

## Do open-source projects suffer from software entropy as much as corporate codebases?
It's my gut feeling that open-source projects should be less prone to entropy, as there is a fundamental difference in how they're built and maintained.

Open-source software is often shaped by end-users themselves - motivated enough to improve the tools they actually use, volunteering to work on the project at their own will. On the other hand, company software is done by mediators - paid software engineers building something for someone else (not out of their own pure interest). This layer of separation between the people writing the code and the people using it, in case of corporate software, can impact the feedback loop negatively, and make the system more vulnerable to entropy over time.

Another reason is visibility. In open-source, code is out, open to the public and every every variable, every method, every class gets judged in pull requests by enthusiasts. Hence this peer pressure alone encourages a better quality and discipline.
But I don't think any system is immune to entropy, including open-source. Imagine contributions coming from many different people, modifications made into inconsistent styles, features half-finished, ownership unclear - all this can easily end in entropy as well, unless OS projects have active maintainers and clear vision.

So, staying vigilant is a must, but an engaged community is a big plus, right?

## How might AI agents influence software entropy in the long run?
Not so easy one, there are a few factors to consider.

AI could easily increase entropy if companies fully delegate their codebases to AI agents for reviews, fixes, features without any supervision. Nothing is perfect, neither is AI. It's lacking the context that we have from countless interactions with our teammates, history of project development and every other subtle experience. Without this context, it may reinforce messy patterns, introduce inconsistencies - good luck with finding those.

Relying on AI for each decision can also reduce our understanding of system over time. If code is just copied from AI chats, without being fully understood by the team, we are getting unclear foundation and a false sense of safety. The more we outsource our decisions, the harder it becomes to refactor or evolve the system confidently. And who's accountable for that?
On the other hand, it can become one of the most valuable tools in our toolkit. When used well, with discipline, it helps us fight entropy by suggesting cleanups, identifying duplication, automating boring but important tasks, or roasting our variable name decisions.

Using AI in development should not mean discouraging critical thinking or abandoning code reviews. On the opposite, it can help ignite discussion around the topic, introduce new approaches to the team, and adoption of best practices.
In short, what we can agree on is that entropy is not only about bad code, but also about unfamiliar, untrusted code. AI can multiply that if we are not careful. BUT if used reasonably, with awareness, if can amplify the good practices and improve quality. It all depends on how we use it.

## Which types of software systems are most vulnerable to entropy?
I believe it heavily depends on the purpose of the software.

Some systems - like molecular simulation software, physics engine, or static math libraries - are not likely to change once they reach the point of maturity - being tested and validated. Because of that, these systems should be relatively less prone to entropy.

Software built around regulation, finance, healthcare, or any similar domain where rules change frequently? That's a different story. Anything involving modeling human behavior or policy decisions is under constant pressure to evolve, as we are encoding all those legacy constraints, rules and thought processes behind it, dealing with exceptions to exceptions.
Systems that rely on lots of external services are walking a fine line. Our code might be clean, but we're still stuck dealing with whatever comes from the outside. I've been on a project where we had to create an entire microservice just to isolate some outdated dependency - because the external team couldn't upgrade, and we couldn't wait. So, there's that.

## Is software entropy inevitable, and how can it be managed effectively?
Turns out, yes - entropy is inevitable if we don't keep an eye on it. It doesn't show up all at once; it creeps in through skipped cleanups, ambiguous ownership, and too many "just a quick fix" moments.

The good news? We can't stop it completely, but we can slow it down and keep it under control by:
- **Regular refactoring** - revisiting old code with fresh eyes, and less pressure to deliver urgently, helps accumulating technical debt.
- **Writing and maintaining tests** - having confidence that our change/improvement will not break unknown corners is what encourages regular refactoring.
- **Enforcing code reviews and coding standards** - I cannot stress it enough, how important it is to keep quality consistent and encourage shared understanding.
- **Applying clean architecture or design patterns** - doing it wisely, not fanatically allows our systems to grow in a healthy way.
- **Using static analysis and linting tools** - for catching smelly code before it becomes a problem.

But above all, entropy is best fought with mindset: a culture of continuous improvement, the team cares not just about shipping, but about shaping the system into something future developers won't run away from.