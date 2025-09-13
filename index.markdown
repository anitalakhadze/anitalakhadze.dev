---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
---

<div class="post-list">
  {% for post in site.posts %}
    <div class="post-item">

      {% if post.title %}
      <div class="post-header">
        <a href="{{ post.url }}">
          <h3>{{ post.title }}</h3>
        </a>
        <small>{{ post.date | date: "%b %d, %Y" }}</small>
      </div>
      {% endif %}

      {% if post.subtitle %}
        <div class="post-subtitle">
          <p>{{ post.subtitle }}</p>
        </div>
      {% endif %}

      <p>{{ post.summary }}</p>
    </div>
  {% endfor %}
</div>