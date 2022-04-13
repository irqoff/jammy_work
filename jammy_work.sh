#!/bin/bash

set -o errexit -o nounset -o xtrace

source ~/jammy_work/ansible.sh

cd ~/jammy_work && ansible-playbook jammy.yml -K --skip-tags brew_package

set +o nounset
source ~/.bashrc
set -o nounset

sudo -u "$USER" bash -ci 'cd ~/jammy_work && ansible-playbook jammy.yml -K -t brew_package --skit-tags go'
sudo -u "$USER" bash -ci 'cd ~/jammy_work && ansible-playbook jammy.yml -K -t go'

set +o errexit +o nounset +o xtrace
