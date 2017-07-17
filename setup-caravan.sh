#!/bin/bash

echo "Let's see how this goes."

# Assuming local development on OSX.
# From https://victorops.com/blog/automating-developer-environment-setup-osx-using-ansible-homebrew-docker/
if [ ! -x /usr/local/bin/brew ]; then
  echo "Installing Homebrew"
  /usr/bin/env ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Homebrew is already installed."
fi

if [ ! -x /usr/local/bin/ansible ]; then
  echo "Installing Ansible via Homebrew."
  brew install ansible
else
  echo "Ansible is already installed."
fi

if [ ! -x /usr/local/bin/docker ]; then
  echo "Installing Docker via wget"
  wget https://download.docker.com/mac/stable/Docker.dmg ~/Downloads/.
  echo "Find Docker.dmg in your Downloads directory and click to install."
  read -p "Have you started the Docker Application? " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    continue
  else
    echo "I'm afraid you can't continue until Docker is running on your machine."
    exit
  fi
else
  echo "Docker is already installed."
fi

# Find where we are running the playbook from
caravan_path=$(find . -type d -name "drupal-caravan")

# Always output Ansible log in color
export ANSIBLE_FORCE_COLOR=true

echo "Running localhost playbook"
ansible-playbook -i $caravan_path/hosts -K \
  $caravan_path/provisioning/localhost-playbook.yml

# Specify connection here because the DrupalVM playbooks
# rely on these variables only, not those in container-playbook.yml
echo "Running container playbook"
ansible-playbook -i $caravan_path/docker.py \
  $caravan_path/provisioning/container-playbook.yml \
  -c docker

echo "Visit http://se3_blt.local:9000"
echo "Or log into your container with: docker exec -it se3_blt bash"
