#!/bin/bash

set -o errexit -o nounset -o xtrace

readonly custom_bashrc="${HOME}/.bashrc_${USER}"
readonly python_version="3.10.4"
readonly venv="ansible"

echo "Installing git"
sudo apt update
sudo apt install -y git

if [[ -d "${HOME}/.pyenv" ]]; then
  cd "${HOME}/.pyenv"
  git pull
  cd
else
  git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
fi

if [[ ! -f "${HOME}/${custom_bashrc}" ]]; then
  echo -e '\n\n# reading custom .bashrc' >> "${HOME}/.bashrc"
  echo "source ${custom_bashrc}" >> "${HOME}/.bashrc"
fi

if [[ ! -f "${custom_bashrc}" ]]; then
  echo '# pyenv_begin' > "${custom_bashrc}"
  echo 'export PYENV_ROOT="${HOME}/.pyenv"' >> "${custom_bashrc}"
  echo 'export PATH="${PYENV_ROOT}/bin:${PATH}"' >> "${custom_bashrc}"
  echo 'eval "$(pyenv init --path)"' >> "${custom_bashrc}"
  echo 'eval "$(pyenv init -)"' >> "${custom_bashrc}"
  echo '# pyenv_end' >> "${custom_bashrc}"
fi

echo "Install dependencies"
sudo apt -y install build-essential libbz2-dev libffi-dev liblzma-dev\
  libncurses5-dev libreadline-dev libsqlite3-dev libssl-dev libxml2-dev\
  libxmlsec1-dev llvm tk-dev

set +o nounset
source "${custom_bashrc}"
set -o nounset

pyenv install "${python_version}"

if [[ -d "${HOME}/.pyenv/plugins/pyenv-virtualenv" ]]; then
  cd "${HOME}/.pyenv/plugins/pyenv-virtualenv"
  git pull
  cd
else
  git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
fi

if grep -qv '# pyenv-virtualenv_begin' "${custom_bashrc}"; then
  echo '# pyenv-virtualenv_begin' >> "${custom_bashrc}"
  echo 'eval "$(pyenv virtualenv-init -)"' >> "${custom_bashrc}"
  echo 'export PYENV_VIRTUALENV_DISABLE_PROMPT=1' >> "${custom_bashrc}"
  echo '# pyenv-virtualenv_end' >> "${custom_bashrc}"
fi

set +o nounset
source "${custom_bashrc}"
set -o nounset

pyenv virtualenv "${python_version}" "${venv}"

set +o nounset
pyenv activate "${venv}"
set -o nounset

echo "ansible" > "${HOME}/jammy_work/.python-version"

pip install ansible docker psutil
ansible --version

set +o errexit +o nounset +o xtrace
