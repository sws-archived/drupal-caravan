#!/bin/bash
command=$1
docker exec -it "{{ sitename }}" sh -c “cd /var/www/{{ sitename }}/docroot && drush $command”
