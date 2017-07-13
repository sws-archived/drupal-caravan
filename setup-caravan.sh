#!/bin/bash

# Requirements:
# Python3 with: brew install python3
# and adding to ~/.bash_profile: alias python='python3'
# check with: python --version
# pip modules: docker-py docker docker-compose
# add to /etc/hosts file locally: 192.168.88.88  se3_blt.local


echo "Let's see how this goes."
# Find where we are running the playbook from
caravan_path=$(find . -type d -name "drupal-caravan")

# see if we can get Ansible to always output color
export ANSIBLE_FORCE_COLOR=true

echo "Running setup-container"
# setup container with local connection
ansible-playbook -i $caravan_path/hosts \
  $caravan_path/provisioning/tasks/setup-container.yml

echo "Running run-drupalvm"
# run DrupalVM ansible playbooks on container
# with Docker connection, I am not sure how to
# specify a connection when using include to
# play the DrupalVM playbooks. Therefore, I am
# using two different ansible-playbook calls
# and specifying the connection here.
ansible-playbook -i $caravan_path/docker.py \
  $caravan_path/provisioning/tasks/run-drupalvm.yml \
  -c docker

echo "Running playbook.yml"
# running DrupalVM ansible playbooks from within
# a playbook, ie provisioning/playbook, including
# tasks/run-drupalvm.yml, which includes the DrupalVM
# playbooks resulted in an error after the 'hosts: all'
# line of the DrupalVM playbooks, so calling them directly
# from a ansible-playbook on run-drupalvm.yml allowed
# them to run successfully on the container.
# Now, returning to a collection of plays.
ansible-playbook -i $caravan_path/docker.py \
  $caravan_path/provisioning/playbook.yml

echo "Visit http://se3_blt.local:9000"
echo "Or log into your container with: docker exec -it se3_blt bash"
echo "If you get Not Found, check /etc/apache2/sites-available/vhosts.conf"
echo "And be sure the DocumentRoot is set to se3_blt."
