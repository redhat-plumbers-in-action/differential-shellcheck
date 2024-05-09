# shellcheck shell=bash

# TODO set up required variables

export INPUT_DISPLAY_ENGINE="${INPUT_DISPLAY_ENGINE:='csgrep'}"
is_debug && echo "DISPLAY_ENGINE: ${INPUT_DISPLAY_ENGINE}"

# Set required variables based on the environment
if is_github_actions; then
  is_debug && echo "Running in GitHub Actions"
else
  is_debug && \
  echo "Running in non GitHub Actions environment" && \
  echo "Functionality is limited"
fi
