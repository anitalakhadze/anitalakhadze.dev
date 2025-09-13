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

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs

# Set working directory
WORKDIR /site

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Copy the rest of the site
COPY . .

# Expose the default Jekyll port
EXPOSE 4000

# Serve the site
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
