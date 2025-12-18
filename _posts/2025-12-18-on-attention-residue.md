---
layout: post
title: Human attention is weird
author: Ani Talakhadze
summary: Context switching isn’t just about interruptions or discipline. Research on attention residue shows that unfinished or weakly closed tasks keep pulling on our attention, even after we move on. How work is scoped, owned, and brought to an end matters more than we usually admit.
---

We developers may argue about many things - starting with how to name variables *(welcome to the club)* and ending with which language or platform deserves the crown. But hating context switching isn't one of them. That's where we stand together like a united front. We hate it with heart, soul, and all our might. And heaven help anyone who suggests otherwise. 

<figure>
    <img src="https://substackcdn.com/image/fetch/$s_!smkG!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F5f961a8e-955b-4512-a97f-111f0684c6f7_766x1200.webp" alt="Context switching meme" style="width:100%">
</figure>

The usual reason is productivity. We firmly believe that context switching destroys it. 

A recent poll by [SwissDevJobs on LinkedIn](https://www.linkedin.com/posts/swissdev-jobs_activity-7399394073096224768-yoXE?utm_source=share&utm_medium=member_desktop&rcm=ACoAABudhzIBv4c2ndxfpisiLNMobRmI7lfBrK4) captured that sentiment perfectly. "Constant context switching" topped the list of productivity killers. No surprise there. I jumped at it myself without hesitation and felt really validated when I saw it win.

<figure>
    <img src="https://i.imgur.com/7ilwtXh.png" alt="Poll by SwissDevJobs on LinkedIn" style="width:100%">
</figure>

Still, the result stayed in mind longer rent-free because something felt missing, the WHY behind.

If context switching were mostly about interruptions, then teams using similar tools and working under similar conditions should struggle in roughly the same way. But they don't. We have all heard or read stories of teams who handle even noisy environments just fine. And others who don't, despite having fewer distractions.

So I went down into the rabbit hole called *academic research*. What I found helped me name things I had sensed before but hadn't quite managed to articulate. At the very least, I hope it gives you better arguments next time you are debating productivity killers with your friends.

There is a concept in psychology called ***attention residue***. It describes what happens when we switch tasks: thoughts from the previous task linger into the next one. [Sophie Leroy studied this in a series of experiments](https://www.sciencedirect.com/science/article/pii/S0749597809000399) published in *Organizational Behavior and Human Decision Processes*. 

The research is careful to distinguish attention residue from related concepts - ruminations, attentional focus or psychological presence, and defines it as evaluative, reflective thoughts about Task A that spill into Task B. It's unintentional, automatic and hard to suppress.

<figure>
    <img src="https://i.imgur.com/I9fmOl5.png" alt="Different types of persistent thoughts" style="width:100%">
</figure>

The idea itself is simple. We move from Task A to Task B, but part of our mind stays behind. We’re technically working on Task B, yet Task A hasn’t let go. The thing is that lingering cognition creates cognitive load, and under cognitive load our performance tends to suffer. 

What's interesting is that this doesn't require multitasking as you might have thought. Even sequential task switching - doing one thing after another - produces attention residue. So the problem isn't how many tasks we have, but how attention transitions between them.

And often it doesn't. 

<figure>
    <img src="https://i.imgur.com/JcwVIRp.png" alt="Our thoughts often stay on the previous task" style="width:100%">
</figure>

It could sound reasonable that thoughts about unfinished work persist and interfere with whatever comes next. More surprisingly though, thoughts persist even after a task is finished. We often keep processing completing tasks, revising them, second-guessing: *could I have done it better?*, *did I miss something?*. How many times have you sold a math problem, written down the answer, and then still wonder whether there was a more elegant solution? That post-completion processing is also an attention residue. 

So if finishing a task doesn’t necessarily end our cognitive engagement with it, what does?

Leroy introduces the idea of cognitive closure. It’s the point at which cognitive processing actually ends - not just objectively, but subjectively. We feel resolved in a way that feels satisfactory.

What helps people reach that point turns out to depend a lot on context. Time pressure, in particular, plays a big role.

Prior research shows that under high time pressure, people narrow the number of alternatives they consider. Exploratory behavior drops. Attention focuses on the fastest path to completion. Under low time pressure, the opposite happens. People stay cognitively open longer, consider more alternatives, and delay final decisions.

<figure>
    <img src="https://i.imgur.com/kfLKaIj.png" alt="High time pressure leads us to dial down exploratory behavior" style="width:100%">
        <figcaption style="text-align: center;">
        High time pressure leads us to dial down exploratory behavior<br>
    </figcaption>
</figure>

There’s more. Studies on decision-making and choice show that the fewer options people consider, the more confident they are once a choice is made. That confidence matters, because it leads to the termination of cognitive effort. People who consider fewer alternatives are more likely to stop thinking about the task once it’s done.

By contrast, people who choose among many alternatives tend to experience more regret - even if they carefully evaluated their options. More thinking doesn’t necessarily buy us more peace of mind.

<figure>
    <img src="https://i.imgur.com/B81rDSY.png" alt="High time pressure leads us to dial down exploratory behavior" style="width:100%">
        <figcaption style="text-align: center;">
        Fewer alternatives lead to more confidence and satisfaction<br>
    </figcaption>
</figure>

All of this suggests that it’s not just whether we finish a task before switching, but how we finish it. Finishing under time pressure seems to increase confidence and reduce attention residue.

<figure>
    <img src="https://i.imgur.com/e33ZmFQ.png" alt="High time pressure leads us to dial down exploratory behavior" style="width:100%">
        <figcaption style="text-align: center;">
        Completing tasks under time pressure leads to more confidence and less attention residue<br>
    </figcaption>
</figure>

Leroy tested this directly in two studies. Participants - undergraduates - worked on a word puzzle (Task A) under conditions of high or low perceived time pressure. The task was framed as either finishable or unfinishable. Afterward, they switched to a different task (Task B), where attention residue was measured using a lexical decision test.

<figure>
    <img src="https://i.imgur.com/SSrhDNe.png" alt="High time pressure leads us to dial down exploratory behavior" style="width:100%">
        <figcaption style="text-align: center;">
        Participants were assigned random categories, and afterwards their performance was measured<br>
    </figcaption>
</figure>

The results were interesting.

People who didn’t finish Task A reacted faster to words related to that task while working on Task B. Their minds were still there.

People who finished Task A under high time pressure showed less attention residue than those under low time pressure.

Simply finishing wasn’t enough. Participants who completed Task A under low time pressure reported more residue than those under high pressure. Time pressure moderated the effect of completion.

<figure>
    <img src="https://i.imgur.com/FZ5UJZq.png" alt="High time pressure leads us to dial down exploratory behavior" style="width:100%">
        <figcaption style="text-align: center;">
        Those who finished Task A under high pressure showed better performance in Task B<br>
    </figcaption>
</figure>

Time pressure, it seems, helps the mind reach cognitive closure.

Attention residue wasn’t just a mental artifact either - it had performance consequences. Participants who finished Task A performed better on Task B than those who didn’t. And those who worked under high time pressure on Task A performed better on Task B than those under low pressure.

Finishing a task under time pressure helps end the associated cognitions. That reduces residue when switching and improves subsequent performance.

This matters even more for work that depends on complex, evolving mental models - which is most development work. We carry assumptions, partial solutions, uncertainties. Switching away and coming back is really expensive operation for us, we have to rebuild what we were working on and get to the same mental state.

So what actually helps reduce attention residue?

As stated above, Leroy’s work suggests that time pressure can facilitate closure. When people decide quickly and narrow alternatives, they’re more confident they’re done - and they stop revisiting the task mentally. Low-pressure environments leave more room for residue to accumulate.

A lot of advice online treats context switching as a personal discipline problem: focus harder, mute notifications, batch meetings. That stuff helps, but it doesn’t really get to the core of it. How work is designed impacts attention residue. 

When our work is sliced too thinly into small tightly coupled tickets, nothing ever fully resolves and we are carrying these half-finished mental models around. 

When ownership is not solid or stable, or knowledge is not properly shared, we have to check, sync, switch more. 

When systems and processes are so fragmented that they don't make sense anymore, we struggle a lot, like A LOT. 

So reducing attention residue isn’t about silencing notifications. That’s the easy part. The harder part is whether work is structured in a way that lets our brain actually let go. Clear ownership helps. Work that’s cohesive helps. Systems that more or less make sense help.

There’s no ready answer here. But one thing comes up again and again in the research: unfinished or weakly closed tasks don’t just disappear when we switch away from them. They keep pulling on attention in the background. Individually that might feel small. Over time it’s not.

While attention residue is something not fully under our control, there are a few things we can do at work to reduce it. This requires careful understanding of the dynamics of the team and processes, but the next time productivity comes up, this blog might be worth keeping in mind.

---

*Diagrams have been sketched in [Excalidraw](https://app.excalidraw.com). If you are not using and loving it, where have you been?*

*Thanks to [**Tornike Onoprishvili**](https://www.linkedin.com/in/tornikeo/) for reading drafts of this.*