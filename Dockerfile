# # Use Debian-slim to avoid musl/alpine issues with sass-embedded
# FROM ruby:3.1-slim

# # Install build deps required by some gems (native extensions and prebuilt binaries)
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#       build-essential \
#       git \
#       curl \
#       ca-certificates \
#       libffi-dev \
#       libgmp-dev \
#       libssl-dev \
#       pkg-config \
#       nodejs \
#       npm && \
#     rm -rf /var/lib/apt/lists/*

# # Use a modern bundler
# RUN gem install bundler -v '2.4.13' --no-document || gem install bundler --no-document

# WORKDIR /srv/jekyll

# # Copy Gemfile and Gemfile.lock first to leverage layer caching
# COPY Gemfile Gemfile.lock* ./

# # Install gems
# RUN bundle install --jobs 4 --retry 3

# # Copy the site
# COPY . .

# EXPOSE 4000

# # Default command: serve on all interfaces so host can access
# CMD ["jekyll", "serve", "--watch", "--drafts", "--config", "_config.yml", "--host", "0.0.0.0", "--port", "4000"]

# Simple Dockerfile for building and serving the Jekyll site
FROM ruby:3.2

# Install build / runtime dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      nodejs \
      npm && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /site

# Copy Gemfiles first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Install bundler and set bundler path to vendor/bundle so gems are isolated to the project
RUN gem install bundler && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install --jobs 4 --retry 3 || true

# Copy entrypoint helper and site
COPY scripts/entrypoint.sh /site/scripts/entrypoint.sh
RUN chmod +x /site/scripts/entrypoint.sh

COPY . .

EXPOSE 4000

# Use entrypoint to ensure gems are installed when the container starts (useful when Gemfile changes on host)
ENTRYPOINT ["/site/scripts/entrypoint.sh"]

# Default dev command: watch, serve and enable livereload so host edits propagate to the browser
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--livereload", "--drafts", "--watch", "--incremental"]
