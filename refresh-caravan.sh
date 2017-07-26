#!/bin/bash
echo "Let's see how this goes."

# Find where we are running the playbook from
caravan_path=$(find . -type d -name "drupal-caravan")

# Always output Ansible log in color
export ANSIBLE_FORCE_COLOR=true

echo "Running localhost playbook"
ansible-playbook -i $caravan_path/provisioning/docker.py -K \
  $caravan_path/provisioning/refresh-playbook.yml \
  -c docker

echo "Visit http://[SITENAME].local:9000"
echo "Or log into your container with: docker exec -it [SITENAME] bash"
