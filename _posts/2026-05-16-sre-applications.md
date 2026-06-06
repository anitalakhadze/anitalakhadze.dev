---
layout: post
title: Spring I/O 2026 Diaries
author: Ani Talakhadze
summary: My first Spring I/O, and easily one of the warmest, most inspiring tech experiences I have had so far.
preview_image: https://i.imgur.com/KvVd1dD.jpeg
community_gathering:
  - src: https://i.imgur.com/AYm2PT7.jpeg
    alt: Community Gathering, Bar Ocaña
    caption: Community Gathering, Bar Ocaña
  - src: https://i.imgur.com/Skk3vAu.jpeg
    alt: Community Gathering, Bar Ocaña
    caption: Community Gathering, Bar Ocaña
  - src: https://i.imgur.com/60S2fzO.jpeg
    alt: Community Gathering, Bar Ocaña
    caption: Community Gathering, Bar Ocaña


---

<!-- <figure>
    <img src="https://i.imgur.com/KvVd1dD.jpeg" alt="Anita in front of conference venue" style="width:100%">
        <figcaption style="text-align: center;">
        Hola from Spring I/O, Barcelona 🍃🇪🇸<br>
    </figcaption>
</figure> -->

{% include carousel.html items=page.community_gathering label="Conference Venue" %}

**From Big Tech to Everyday Work: What Google’s SRE Culture Taught Me About Reliability**

When people hear “Site Reliability Engineering” (SRE), they usually think of huge production systems, fleets of servers, and pagers going off at 3 a.m. But the most interesting part of SRE, at least for me, isn’t the scale or the tooling. It’s the way Google treats reliability as a cultural practice — and how that practice can apply far beyond software.

I’ve been reading through Google’s public SRE material, and it’s surprisingly accessible. Underneath the Borgs and Bigtables are habits any team can borrow: how to react to incidents, how to learn from failure, and how to launch changes more safely. In this post, I’ll walk through a few of those habits and show how they map neatly onto non‑software work.

---

### SRE in one sentence (for non‑engineers)

Different companies define SRE slightly differently, but a good working description is:

SRE is a discipline that combines software engineering and operations to build reliable, scalable services — and treats operations problems as engineering problems.

The key word is discipline. It’s not just a job title; it’s a set of practices. Google has made a lot of those practices public, and that’s where things get interesting for everyone else.

---

### How Google makes incidents “thinkable”

One of my favorite examples from the SRE book is the fictional “Shakespeare Sonnet++” outage. It’s written like a real internal incident:

- There’s an **incident state document**, with a summary, the current status, who’s in charge, and a running timeline of what’s happening.
- There’s a **postmortem** afterward, with a clear summary, impact, root causes, a detailed timeline, and a table of action items with owners.
- There are **production meeting minutes** that treat outages, capacity, and key metrics as normal agenda items — not ad‑hoc emergencies.
- There’s even a **launch coordination checklist** for new releases, covering architecture, capacity, monitoring, failure modes, security, and rollout plans.

Individually, none of these documents is exotic. Together, they add up to something powerful:

- Incidents are described in plain language.  
- Roles and responsibilities are explicit.  
- The same structure is used every time.  
- The focus is on learning and prevention, not finding someone to blame.

That last point — the blamelessness — is what unlocks everything else.

---

### Blameless postmortems: A culture of “the cost of failure is education”

Google is outspoken about its postmortem philosophy: a postmortem is a learning tool, not a punishment. The goal is to document what happened, understand all the contributing causes, and commit to concrete improvements.

Two details are worth calling out:

1. **Blameless by design**  
   The template and the review culture intentionally avoid finger‑pointing. The assumption is that people did the best they could with the information and tools they had. If something went badly, it’s the system and processes that need to change.

2. **Formal review and sharing**  
   Postmortems don’t just live in someone’s personal folder. They’re reviewed, improved, and then shared widely so other teams can learn. There are even “postmortem reading clubs” and internal spotlights on particularly good examples.

You don’t need distributed systems to benefit from that. Any team that occasionally breaks things — which is all teams — can adopt a similar pattern:

- After any meaningful incident, write a short, structured postmortem.  
- Focus on “how our system allowed this to happen,” not “who messed up.”  
- Extract two or three realistic action items with clear owners and priorities.  
- Review and share it so others can reuse the lessons.

The result is a culture where people escalate early, tell the truth about what’s happening, and are more willing to experiment because recovery is a learning process, not a career risk.

---

### Checklists and runbooks: Making reliability boring on purpose

Another theme that jumps out from Google’s SRE material is the unapologetic love of templates and checklists. There’s a launch coordination checklist that covers everything from capacity estimates to failure scenarios. There are example production meeting minutes where the same headings appear every week. There are incident documents that always list status, exit criteria, and a timestamped timeline.

The goal isn’t bureaucracy. The goal is to make the critical things **predictable**:

- Before a launch, you always think about: what happens if a data center goes offline? how do we roll back? what metrics will we watch?  
- During an incident, you always know: who is the incident commander, where coordination happens, what “done” looks like (the exit criteria).  
- After an incident, you always capture: impact, root causes, timeline, and action items.

This style of thinking is just as relevant outside of software:

- A marketing team launching a campaign can borrow the launch checklist idea: have we tested tracking? what’s our rollback if something misfires? what’s our capacity for support tickets?  
- An operations team running a physical process can standardize incident docs: who is leading, how we’re communicating, what our safety exit criteria are.  
- A customer support team can run weekly “production meetings” where they review key metrics, recent incidents, and upcoming risk changes.

If you’ve ever read Atul Gawande’s “Checklist Manifesto,” Google’s SRE practice feels like the same philosophy applied to distributed systems.

---

### Error budgets: Deciding how reliable is “reliable enough”

One more SRE concept worth exporting is the idea of **error budgets**. In short:

- You define a target level of reliability (for example, 99.9% availability).  
- The remaining 0.1% is your error budget — the allowed “failure time” over a period.  
- If you burn through that budget, you slow down risky changes until reliability is back on track.

Why does this matter outside of software?

Because in any domain, you’re trading off **speed vs. stability**. You want to move fast, but not at the cost of completely eroding trust. An explicit error budget forces an honest conversation:

- What level of disruption is acceptable to our customers/users/partners?  
- How will we notice when we’re exceeding it?  
- What do we commit to do when we’ve gone too far — do we pause launches, add tests, change review processes?

You can apply this pattern to customer support response times, operational defects, marketing send errors, or even internal process changes. The reliable thing isn’t “never fail”; it’s “agree on how much failure we accept, measure it, and react deliberately.”

---

### Making this concrete for non‑software teams

If you’re curious to experiment with SRE thinking outside of traditional engineering, here’s a small starter kit you can try with almost any process:

1. **Introduce a simple incident template**  
   For any meaningful outage, defect, or “oh no” moment, capture:
   - Summary in two or three sentences  
   - Impact (who was affected and how)  
   - Timeline (a few key timestamps and events)  
   - Root causes (system and process factors)  
   - Two or three action items with owners and target dates

2. **Run a blameless review**  
   Schedule a short review where the rule is: we’re not here to judge people, only to improve the system. Stick to that.

3. **Create a lightweight launch checklist**  
   For recurring types of launches — campaigns, process rollouts, events — list the small set of questions you always wish you’d asked beforehand. Use it every time, and refine it as you learn.

4. **Keep language clear and accessible**  
   One nice parallel here comes from Apple’s own writing guidelines: be clear, concise, and action‑oriented. Avoid jargon that only insiders understand. When you’re writing incident docs or postmortems, the test is simple: could someone new to the team read this and understand what happened and what we’re doing next?

None of this requires being Google‑sized. It just requires a willingness to write things down, revisit them, and treat failures as data.

---

### The real lesson: you can’t fix people, but you can fix systems

The most transferable idea from Google’s SRE culture, at least in my view, is this: rather than treating incidents as proof that someone is incompetent, treat them as proof that your **system** is still learnable.

If you build a culture where:

- Incidents are documented, not buried.  
- Postmortems are blameless, but not toothless.  
- Checklists and templates reduce cognitive load when things are stressful.  
- Improvement work is tracked with owners, not left as “we should.”  

…then it almost doesn’t matter whether you’re running servers, hosting events, or operating a warehouse. You’ve adopted the core of SRE: using structured thinking and written practice to make reliability a property of your system, not a hope pinned on individual heroics.

That’s the part of Google’s SRE approach I find most interesting — and the part that quietly scales to almost any kind of work.




---

*Thanks to [**Tornike Onoprishvili**](https://www.linkedin.com/in/tornikeo/) for sponsoring this section of the blog.*
