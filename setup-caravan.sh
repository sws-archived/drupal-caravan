#!/bin/bash

read -p "Will this be for a local or CI environment? " inventory
read -p "What should we call your site, ie. earth? " sitename

# add sitename to hosts

ansible-playbook -i $inventory $DRUPALVM_PROJECT_ROOT/vendor/su-sws/drupal-caravan/provisioning/playbook.yml
