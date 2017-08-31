#!/bin/bash
# This quick test script can be run from anywhere

# Currently testing drush aliases for behat testing

git clone git@github.com:stanford-earth/SE3_BLT.git ~/Sites/caravan
cd ~/Sites/caravan
TRAVIS_BUILD_DIR=$(pwd)

composer self-update
composer install --dev
caravan_path=$(find . -type d -name "drupal-caravan")
rm -rf $caravan_path
git clone https://github.com/SU-SWS/drupal-caravan.git $caravan_path
cp $caravan_path/travis.caravan.yml $TRAVIS_BUILD_DIR/caravan.yml
ansible-playbook -i $caravan_path/provisioning/inventory $caravan_path/provisioning/setup-playbook.yml -c docker || true
docker exec -it "caravan" /var/www/caravan/vendor/bin/blt sws:behat -Dbehat.tags='@deploy,@example'
