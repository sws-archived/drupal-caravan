# Drupal Caravan (deprecated)
Pieces have been moved to separate repositories for further development.

##### Version: 8.x-1.x

Maintainers: [kbrownell](https://github.com/kbrownell)  

Changelog: [Changelog.txt](CHANGELOG.txt)

Description
---

Most simply, Caravan is a set of scripts that allow us to integrate existing continuous integration tools, like Travis and BLT, into our development workflow.  In the language of supply chain or transportation management, Caravan covers the last mile.

Scripts are organized and run with Ansible.  We run as much as possible within the controlled environment of a Docker container based on a DrupalVM image, which can move between pieces of the CI toolchain.  And, as much as possible, take advantage of features provided by each piece of the toolchain.

For example, BLT excels at installing a Drupal site and refreshing the database and files from production.  Instead of writing custom scripts to manage these actions, we’ll use BLT commands.

Installation
---

1. You'll need permissions and ssh access to a site on Acquia.
2. You'll also need to clone a local copy of the site you want to build, and run `composer install`.
3. Create a local copy of the caravan.yml configuration file and save it in the root directory of your build repository, ie. `cp vendor/su-sws/drupal-caravan/default.caravan.yml caravan.yml`.  Update values specific to your local machine.
4. From the root directory of a build repository run, `vendor/bin/blt sws:caravan`.
5. After a very long while, you should be able to find your site at http://[SITENAME].local:9000.

Troubleshooting
---

Every personal machine is different.  You may have an old version of python systemtools that causes problems.  Or an application already running on port 9000.  We are keeping a list of known issues in this quickly changing [document](https://docs.google.com/document/d/1DAoQHLwqRwjRmY-_oCjhcN1VJAritX-aaqXEK_ooMj8/edit#).

Contribution / Collaboration
---

You are welcome to contribute functionality, bug fixes, or documentation to this module. If you would like to suggest a fix or new functionality you may add a new issue to the GitHub issue queue or you may fork this repository and submit a pull request. For more help please see [GitHub's article on fork, branch, and pull requests](https://help.github.com/articles/using-pull-requests)
