---
layout: post
title: Git Squash or Squashn’t?!
author: Ani Talakhadze
summary: Spoiler Alert - It depends
---

![* Squash — The fruit of edible species is usually served as a cooked vegetable.](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*5wLgv12oG7pTrpYI.jpg)

We’ve all been there — staring at a long list of commits with messages like _“fix typo,”_ _“missing file,”_ or the adorable _“final final version.”_ A lot of intrusive thoughts may be roaming wildly into our heads, but one of them could be:

> _should I squash them into a single commit or let them stay as they are?_

At one point, I was team _leave-them-be_, and now I’m fully on team _squash-them-at-any-price_. But, I’ve been thinking and like most things in tech, the answer is

![captionless image](https://miro.medium.com/v2/resize:fit:800/format:webp/0*E5Bx1jB92uOUXF96.jpg)

**When Squashing Makes Sense**
------------------------------

Squashing is a great way to keep our commit history clean and readable, especially in these scenarios:

### **🟢 Before Merging a Feature Branch**

When working on a feature, we might have multiple commits that represent trial-and-error steps. While that history was useful during development, does the main branch _(or anybody, for that matter)_ really need to know that we tried three different variable names? Or what were the steps of implementation? Probably not _(seriously, not!)_. Squashing them into a single, meaningful commit results in a cleaner history.

![Merging a feature branch: BEFORE squashing](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*nMF35mGxbII5qpznNfYLww.png)![Merging a feature branch: AFTER squashing](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*wYCT9WfkiL8dHKVDISlHsA.png)

### 🟢 **Reducing Noise in Commit Logs**

Similarly, commits like _“fix typo,”_ _“adjust indentation,”_ or _“forgot to push this”_ don’t add much value on their own. If your branch is full of these, consider squashing them before merging.

### 🟢 **Making PR Reviews Easier**

A single well-structured commit tells a clear story, making it easier for reviewers to understand what changed and why. Instead of asking them to scroll through ten micro-commits, a single commit with a clear message keeps things efficient.

**When Not to Squash**
----------------------

Despite all the above, I have discovered that squashing isn’t always the best choice. Here’s when you might want to keep commits separate:

### **🟡 Preserving Valuable History**

If each commit represents a meaningful step in development _(e.g., removing a scheduled monitoring job, implementing a new API, fixing a related bug meanwhile and then adding logging)_, keeping them separate can make it easier to track down changes or bugs later.

### 🟡 **Working in a Team That Values Granular Commits**

Some teams prefer a commit history that reflects the natural progression of work, including small fixes. Until you squash, first think if it aligns with your team’s coding philosophy.

**🥁 Best Practices**
---------------------

*   Commit as you wish during development _(add as many “fix bug”, “add feature”, “remove script” as you dare)_, as it might serve helpful at some point to be able to reconstruct the steps backward. BUT squash before merging — remember, your colleagues will want to understand what’s going on in the code, not play a guessing game.
*   If you want to be selective and squash some commits, while keeping rest intact, use `git rebase -i HEAD~N` . It’s a quite useful command and I’m sure you will find tons of tutorials for using it.
*   Ask around the team, discuss your workflow and align the strategy. Communication is the key.

Squashing is like refactoring commit history and nothing feels better than destroying all the noise in the log and leaving one meaningful message about what was really done. But be aware, overdoing it could remove valuable context _(for starters, don’t forget that squashing will create a new hash)_.

**_Thanks for reading and stay tuned for the future blogs ✨_**