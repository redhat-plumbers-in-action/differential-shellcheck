# shellcheck shell=bash

# TODO set up required variables

# Set required variables based on the environment
if is_github_actions; then
  is_debug && echo "Running in GitHub Actions"
else
  is_debug && \
  echo "Running in non GitHub Actions environment" && \
  echo "Functionality is limited"
fi
