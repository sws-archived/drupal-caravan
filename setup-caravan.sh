#!/bin/bash

# read -p "What should we call your site, ie. earth? " sitename
echo "Let's see how this goes."
# add sitename to hosts

ansible-playbook -i "hosts" provisioning/playbook.yml -e "ansible_python_interpreter=/usr/local/bin/python3"
