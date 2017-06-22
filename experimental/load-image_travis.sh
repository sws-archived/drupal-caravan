#!/bin/bash
#
# Use a Docker container baked with Drupal VM.

# Exit on any individual command failure.
set -e

# Set variables.
DRUPALVM_MACHINE_NAME="${DRUPALVM_MACHINE_NAME:-earth}"
DRUPALVM_HOSTNAME="${DRUPALVM_HOSTNAME:-earth.local}"
DRUPALVM_PROJECT_ROOT="${DRUPALVM_PROJECT_ROOT:-/var/www/earth}"

DISTRO="${DISTRO:-ubuntu1604}"
OPTS="${OPTS:---privileged}"
INIT="${INIT:-/lib/systemd/systemd}"

# Helper function to colorize statuses.
function status() {
  status=$1
  printf "\n"
  echo -e -n "\033[32m$status"
  echo -e '\033[0m'
}

# Set volume options.
if [[ "$OSTYPE" == "darwin"* ]]; then
  volume_opts='rw,cached'
else
  volume_opts='rw'
fi

# Run the container.
status "Bringing up Docker container..."
docker run --name=$DRUPALVM_MACHINE_NAME -d \
  --add-host "$DRUPALVM_HOSTNAME":127.0.0.1 \
  -v $PWD:$DRUPALVM_PROJECT_ROOT/:$volume_opts \
  $OPTS \
  earth:latest \
  $INIT
