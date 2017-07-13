#!/bin/bash

echo "Let's see how this goes."

# Assuming local development on OSX.
# Install Homebrew if needed and Ansible if needed.
# From https://victorops.com/blog/automating-developer-environment-setup-osx-using-ansible-homebrew-docker/
if [ ! -x /usr/local/bin/brew ]; then
    echo "installing homebrew"
    /usr/bin/env ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "homebrew is installed"
fi

if [ ! -x /usr/local/bin/ansible ]; then
    echo "installing ansible via homebrew"
    brew install ansible
else
    echo "ansible is installed"
fi

# Find where we are running the playbook from
caravan_path=$(find . -type d -name "drupal-caravan")

# Always output Ansible log in color
export ANSIBLE_FORCE_COLOR=true

echo "Running setup-container"
ansible-playbook -i $caravan_path/hosts \
  $caravan_path/provisioning/tasks/setup-container.yml

echo "Running run-drupalvm"
ansible-playbook -i $caravan_path/docker.py \
  $caravan_path/provisioning/tasks/run-drupalvm.yml \
  -c docker

echo "Running playbook.yml"
ansible-playbook -i $caravan_path/docker.py \
  $caravan_path/provisioning/playbook.yml

echo "Visit http://se3_blt.local:9000"
echo "Or log into your container with: docker exec -it se3_blt bash"
