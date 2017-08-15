# Drupal Caravan

1.0.0-rc
--------------------------------------------------------------------------------
_Release Date: 2017-08-15

- Using BLT to refresh site database, still using drush to sync files.
- Added vhost for behat test results, so html output can be found at behat.[sitename].local.
- Removed DrupalVM value for database user and name, so we will be using the BLT and DrupalVM default of `drupal` for both values.
- Caravan now copies into place the behat config file we’ll want to use.
- Avoided resolving a conflict between different docker-related python packages required by docker.py and the docker_container Ansible module.  By downloading the image as a separate task, we avoid having to install the docker and docker-compose python packages.
- Refreshing Ansible inventory after creating the new container, so that it can switch in the same playbook from running on the local host in one play, to a newly created container in the next play.
- Gives users the option to run behat tests after the container has been configured by DrupalVM.

1.0.0-beta
--------------------------------------------------------------------------------
_Release Date: 2017-07-20

- Moved caravan.yml to build repo root, as the acquia setup process now runs `composer update`, which destroys the vendor/su-sws/drupal-caravan directory and everything in it.  We'll need to exclude caravan.yml from build repo.
- Moved default variables to host group specific group_vars files.  And all possible variable customizations to a single, default.caravan.yml file.  This has the disadvantage of leaving roles without their own self-contained default variables.  But it has the advantage of allowing a user to specify different variables for different hosts.
- Changed variable names to reflect which host this variable will affect.
- Moved hosts file and docker.py to inventory directory and specified inventory path with ansible.cfg file.  Ansible.cfg is also available now for further custom config options down the road, like logging.
- Added standardized documentation to variables files, roles, and playbooks.  Documentation includes known issues or areas for improvement, with links to project issues we’re actively monitoring.
- Added an uninstall task to remove the /etc/hosts entry and IP alias.

1.0.0-alpha
--------------------------------------------------------------------------------  
_Release Date: 2017-07-20

- Initial Release
- Sets up a DrupalVM configured Docker container, on OSX only.
- Installs production database and files from Acquia hosted site.
