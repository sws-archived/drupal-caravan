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

if [ ! -x /usr/local/bin/docker ]; then
    echo "installing docker via homebrew"
    brew install docker
else
    echo "docker is installed"
fi

read -p "Have you started the Docker Application? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
  continue
else
  echo "I'm afraid you can't continue until Docker is running on your machine."
  exit
fi

# Find where we are running the playbook from
caravan_path=$(find . -type d -name "drupal-caravan")

# Always output Ansible log in color
export ANSIBLE_FORCE_COLOR=true

echo "Running localhost playbook"
ansible-playbook -i $caravan_path/hosts \
  $caravan_path/provisioning/localhost-playbook.yml

echo "Running container playbook"
ansible-playbook -i $caravan_path/docker.py \
  $caravan_path/container-playbook.yml \
  -c docker

echo "Visit http://se3_blt.local:9000"
echo "Or log into your container with: docker exec -it se3_blt bash"
