#!/bin/bash
echo "Let's see how this goes."

echo "Install python packages"
if [ ! -f /usr/local/bin/pip ]; then sudo easy_install pip; fi
# Leaving this off for now, but may be necessary
# on old machines
# sudo pip install --upgrade pip setuptools --ignore-installed

# Removed -y because pip was complaining on Travis that there is no such option.
# yaml_package=$(pip list --format=legacy | grep "pyyaml")
ansible_package=$(pip list --format=legacy | grep "ansible")
dockerpy_package=$(pip list --format=legacy | grep "docker-py")
# dockercompose_package=$(pip list --format=legacy | grep "docker-compose")
# if [ -z "$yaml_package" ]; then sudo pip install pyyaml; fi
if [ -z "$ansible_package" ]; then sudo pip install ansible==2.3.1.0; fi
if [ -z "$dockerpy_package" ]; then sudo pip install docker-py==0.4.1; fi
# if [ -z "$dockercompose_package" ]; then sudo pip install docker-compose; fi

if [ ! -x /usr/local/bin/docker ] && [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Installing Docker via wget"
  wget https://download.docker.com/mac/stable/Docker.dmg $HOME/.
  echo "Find Docker.dmg in your $HOME directory and click to install."
  read -p "Have you started the Docker Application? " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    continue
  else
    echo "I'm afraid you can't continue until Docker is running on your machine."
    exit
  fi
else
  echo "Docker is already installed."
fi

# Find where we are running the playbook from
caravan_path=$(find . -type d -name "drupal-caravan")

# Always output Ansible log in color
export ANSIBLE_FORCE_COLOR=true

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Running this script will add a line to your /etc/hosts file and an IP"
  echo "alias on your local machine. Enter your password if you wish to continue."

  echo "Running localhost playbook"
  ansible-playbook -i $caravan_path/provisioning/inventory -K \
    $caravan_path/provisioning/setup-playbook.yml \
    -c docker
else
  ansible-playbook -i $caravan_path/provisioning/inventory \
  $caravan_path/provisioning/setup-playbook.yml \
  -c docker
fi

echo "Visit http://[SITENAME].local:9000"
echo "Or log into your container with: docker exec -it [SITENAME] bash"
