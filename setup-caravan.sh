#!/bin/bash
#
# This script assumes you are running this file from the repository root directory.
# For example, /var/www/se3_blt

# Setup config file paths
BLT_PROJECT_CONFIG="vendor/su-sws/drupal-caravan/config/project.local.yml"
BEHAT_LOCAL_CONFIG="vendor/su-sws/drupal-caravan/config/behat.local.yml"
BEHAT_DEFAULT_CONFIG="vendor/su-sws/drupal-caravan/config/behat.yml"
DRUPALVM_CONFIG="vendor/su-sws/drupal-caravan/config/drupalvm.config.yml"
DRUSH_ALIAS="vendor/su-sws/drupal-caravan/config/aliases.drushrc.php"

# Copy config files into place
cat $BLT_PROJECT_CONFIG >> blt/project.local.yml
cat $BEHAT_LOCAL_CONFIG >> tests/behat/behat.local.yml
cat $BEHAT_DEFAULT_CONFIG >> tests/behat/behat.yml
cat $DRUPALVM_CONFIG >> vendor/geerlingguy/drupal-vm/config.yml
cat $DRUSH_ALIAS >> drush/site-aliases/aliases.drushrc.php

# Bake a Docker container with Drupal VM.

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
if [ "$ENVIRONMENT" == "travis" ]; then
  docker run --name=$DRUPALVM_MACHINE_NAME -d \
    --add-host "$DRUPALVM_HOSTNAME":127.0.0.1 \
    -v $PWD:$DRUPALVM_PROJECT_ROOT/:$volume_opts \
    $OPTS \
    geerlingguy/docker-$DISTRO-ansible:latest \
    $INIT
else
  docker run --name=$DRUPALVM_MACHINE_NAME -d \
    --add-host "$DRUPALVM_HOSTNAME":127.0.0.1 \
    -v $PWD:$DRUPALVM_PROJECT_ROOT/:$volume_opts \
    -p $DRUPALVM_IP_ADDRESS:$DRUPALVM_HTTP_PORT:80 \
    -p $DRUPALVM_IP_ADDRESS:$DRUPALVM_HTTPS_PORT:443 \
    -v $HOME/.ssh/acquia_id_rsa:/root/.ssh/id_rsa \
    -v $HOME/.ssh/acquia_id_rsa.pub:/root/.ssh/id_rsa.pub \
    $OPTS \
    geerlingguy/docker-$DISTRO-ansible:latest \
    $INIT
fi

# Create Drupal directory.
docker exec $DRUPALVM_MACHINE_NAME mkdir -p $DRUPALVM_PROJECT_ROOT

# Set things up and run the Ansible playbook.
status "Running setup playbook..."
docker exec --tty $DRUPALVM_MACHINE_NAME env TERM=xterm \
  ansible-playbook $DRUPALVM_PROJECT_ROOT/vendor/geerlingguy/drupal-vm/tests/test-setup.yml

status "Provisioning Drupal VM inside Docker container..."
docker exec $DRUPALVM_MACHINE_NAME env TERM=xterm ANSIBLE_FORCE_COLOR=true \
  ansible-playbook $DRUPALVM_PROJECT_ROOT/vendor/geerlingguy/drupal-vm/provisioning/playbook.yml

status "...done!"
status "Visit the Drupal VM dashboard: http://$DRUPALVM_IP_ADDRESS:$DRUPALVM_HTTP_PORT"

status "Install BLT alias and vim"
docker exec $DRUPALVM_MACHINE_NAME /var/www/earth/vendor/acquia/blt/scripts/blt/install-alias.sh -y

status "Add ssh key"
docker exec $DRUPALVM_MACHINE_NAME sh -c 'eval "$(ssh-agent)"'
docker exec $DRUPALVM_MACHINE_NAME sh -c "ssh-keyscan earthstg.ssh.prod.acquia-sites.com >> /root/.ssh/known_hosts"

status "Installing Chrome 59.0.3071.104"
docker exec $DRUPALVM_MACHINE_NAME sudo apt-get install libxss1 libappindicator1 libindicator7 vim wget -y
docker exec $DRUPALVM_MACHINE_NAME wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Unpackaging chrome returns an error because it is missing dependencies, which is not a problem,
# We install them a moment later.  So adding || true to be sure this behavior does not quite the script.
docker exec $DRUPALVM_MACHINE_NAME sudo dpkg -i google-chrome-stable_current_amd64.deb || true
docker exec $DRUPALVM_MACHINE_NAME sudo apt-get -f install -y
docker exec $DRUPALVM_MACHINE_NAME google-chrome --version

status "Installing Chromedriver"
docker exec $DRUPALVM_MACHINE_NAME wget https://chromedriver.storage.googleapis.com/2.30/chromedriver_linux64.zip
docker exec $DRUPALVM_MACHINE_NAME unzip chromedriver_linux64.zip
docker exec $DRUPALVM_MACHINE_NAME sudo mv -f chromedriver /usr/local/share/chromedriver
docker exec $DRUPALVM_MACHINE_NAME sudo ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
docker exec $DRUPALVM_MACHINE_NAME sudo ln -s /usr/local/share/chromedriver /usr/bin/chromedriver
status "Starting Selenium"
docker exec $DRUPALVM_MACHINE_NAME service selenium start

status "Installing Site, this make take a while"
# Forcing this to resolve as true, so the script may continue.
# Content is not able to be imported at the comment.
docker exec $DRUPALVM_MACHINE_NAME sh -c "cd /var/www/earth && vendor/bin/blt local:refresh || true"

status "Running tests"
docker exec $DRUPALVM_MACHINE_NAME sh -c "cd /var/www/earth/tests/behat && ../../vendor/bin/behat -p local --colors features"

# Do not run in continuous integration environments
if [ -z "$ENVIRONMENT" ]; then
  read -p "Would you like to log into the test environment? Yes to login, No to quit. " -n 1 -r
  echo "\n"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker exec -it $DRUPALVM_MACHINE_NAME bash
  else
   exit
  fi
fi
