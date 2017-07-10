#!/bin/bash

echo "Let's see how this goes."
# Find where we are running the playbook from
caravan_path=$(find . -type d -name "drupal-caravan")

ansible-playbook -i $caravan_path/hosts \
  $caravan_path/provisioning/playbook.yml \
  -e "ansible_python_interpreter=/usr/local/bin/python3"
