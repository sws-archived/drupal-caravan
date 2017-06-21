#!/bin/bash
#
# Use a Docker container baked with Drupal VM.

# Exit on any individual command failure.
set -e

# Set variables.
DRUPALVM_IP_ADDRESS="${DRUPALVM_IP_ADDRESS:-192.168.88.88}"
DRUPALVM_MACHINE_NAME="${DRUPALVM_MACHINE_NAME:-earth}"
DRUPALVM_HOSTNAME="${DRUPALVM_HOSTNAME:-earth.local}"
DRUPALVM_PROJECT_ROOT="${DRUPALVM_PROJECT_ROOT:-/var/www/earth}"

DRUPALVM_HTTP_PORT="${DRUPALVM_HTTP_PORT:-9000}"
DRUPALVM_HTTPS_PORT="${DRUPALVM_HTTPS_PORT:-9001}"

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
  -p $DRUPALVM_IP_ADDRESS:$DRUPALVM_HTTP_PORT:80 \
  -p $DRUPALVM_IP_ADDRESS:$DRUPALVM_HTTPS_PORT:443 \
  $OPTS \
  earth:latest \
  $INIT
