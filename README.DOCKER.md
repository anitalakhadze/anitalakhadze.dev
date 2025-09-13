Run the Jekyll site using Docker Compose

Requirements
- Docker (Desktop or Engine) and docker-compose

Quick start
1. Build the image (required the first time or after Gemfile changes) and run the Jekyll dev server:

    docker-compose build
    docker-compose up

2. Open http://localhost:4000 to view the site.

Notes
- The compose file now builds a local `Dockerfile` that runs `bundle install` inside a Debian-slim image. This avoids known issues with `sass-embedded` on alpine/musl.
- To build static files and serve them with the optional `web` service, run:

   docker-compose run --rm jekyll jekyll build
   docker-compose up web

- Changes to `_config.yml` require restarting the jekyll service.
