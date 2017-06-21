#!/bin/bash

# This will cause ansible to choke and kill your container
# if run more than once on the same container.
# I will be adding an if statement to be sure that does not happen.
/var/www/earth/vendor/acquia/blt/scripts/blt/install-alias.sh -y
source /root/.bashrc

# You will also need to create keys (ie. id_rsa) for your container and them to
# your acquia account in order to use blt local:refresh.
