#!/usr/bin/env bash
set -euo pipefail

# If Gemfile changed on host, ensure dependencies are installed into vendor/bundle
if [ -f /site/Gemfile ]; then
  echo "Checking/installing gems..."
  bundle check || bundle install --jobs 4 --retry 3
fi

# Execute whatever command was passed to the container
exec "$@"
