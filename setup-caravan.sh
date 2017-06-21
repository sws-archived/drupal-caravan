#!/bin/bash

# Currently, this is a destructive process.
# It will modify files in your working copy of the repository.

# It assumes you are running this file from the repository root directory.
# For example, /var/www/se3_blt

# Copy config files into place
yes | cp -rf vendor/kbrownell/drupal-caravan/blt/project.local.yml blt/project.local.yml
yes | cp -rf vendor/kbrownell/drupal-caravan/blt/project.yml blt/project.yml

yes | cp -rf vendor/kbrownell/drupal-caravan/tests/behat/behat.yml tests/behat/behat.yml

yes | cp -rf vendor/kbrownell/drupal-caravan/vendor/geerlingguy/drupal-vm/config.yml vendor/geerlingguy/drupal-vm/config.yml
yes | cp -rf vendor/kbrownell/drupal-caravan/vendor/geerlingguy/drupal-vm/bake.sh vendor/geerlingguy/drupal-vm/bake.sh
yes | cp -rf vendor/kbrownell/drupal-caravan/vendor/geerlingguy/drupal-vm/load-image_local.sh vendor/geerlingguy/drupal-vm/load-image_local.sh
yes | cp -rf vendor/kbrownell/drupal-caravan/vendor/geerlingguy/drupal-vm/load-image_travis.sh vendor/geerlingguy/drupal-vm/load-image_travis.sh

# Add local alias
cat aliases.drushrc.php >> drush/site-aliases/aliases.drushrc.php

# Build test environment
pwd
vendor/geerlingguy/drupal-vm/bake.sh
