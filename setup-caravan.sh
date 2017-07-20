#!/bin/bash
echo "Let's see how this goes."

echo "Install pip and upgrade systemtools"
if [ -z $(python -c "import pip") ]; then sudo easy_install pip; fi
pip install --upgrade pip setuptools

echo "Install python packages"
if [ -z $(python -c "import ppyaml") ]; then sudo pip install ppyaml; fi
if [ -z $(python -c "import ansible") ]; then sudo pip install ansible; fi
if [ -z $(python -c "import docker-py") ]; then sudo pip install docker-py; fi
if [ -z $(python -c "import docker-compose") ]; then sudo pip install docker-compose; fi

if [ ! -x /usr/local/bin/docker ]; then
  echo "Installing Docker via wget"
  wget https://download.docker.com/mac/stable/Docker.dmg ~/Downloads/.
  echo "Find Docker.dmg in your Downloads directory and click to install."
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

echo "Running localhost playbook"
ansible-playbook -i $caravan_path/provisioning/docker.py -K \
  $caravan_path/provisioning/playbook.yml \
  -c docker

echo "Visit http://[SITENAME].local:9000"
echo "Or log into your container with: docker exec -it [SITENAME] bash"
