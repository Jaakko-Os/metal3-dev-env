#!/usr/bin/env bash
set -ex

source lib/logging.sh

# sudo apt install -y libselinux-utils
# if selinuxenabled ; then
#     sudo setenforce permissive
#     sudo sed -i "s/=enforcing/=permissive/g" /etc/selinux/config
# fi

# Update to latest packages first
sudo apt -y update

# Install EPEL required by some packages
# if [ ! -f /etc/yum.repos.d/epel.repo ] ; then
#     if grep -q "Red Hat Enterprise Linux" /etc/redhat-release ; then
#         sudo yum -y install http://mirror.centos.org/centos/7/extras/x86_64/Packages/epel-release-7-11.noarch.rpm
#     else
#         sudo yum -y install epel-release --enablerepo=extras
#     fi
# fi

# Work around a conflict with a newer zeromq from epel
# if ! grep -q zeromq /etc/yum.repos.d/epel.repo; then
#   sudo sed -i '/enabled=1/a exclude=zeromq*' /etc/yum.repos.d/epel.repo
# fi

# Install required packages

sudo apt -y install \
  crudini \
  curl \
  dnsmasq \
  figlet \
  zlib1g-dev \
  libssl1.0-dev \
  nmap \
  patch \
  psmisc \
  python-pip \
  wget

# Check if 'ifconfig' is available!
if [[ ! $(ifconfig) ]]; then
  echo "Cannot run ifconfig..."
  echo "Install net-tools package"
  sudo apt -y install net-tools
fi


# Install pyenv
if [[  $(cat ~/.bashrc) != *PYENV_ROOT* ]]; then
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
  echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
  fi
fi

pyenv install 2.7.5
pyenv versions
pyenv global 2.7.5
# There are some packages which are newer in the tripleo repos

# Setup yarn and nodejs repositories
#sudo curl -sL https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Add this repository to install podman
sudo add-apt-repository -y ppa:projectatomic/ppa
# Add this repository to install Golang 1.12
sudo add-apt-repository -y ppa:longsleep/golang-backports

# Update some packages from new repos
sudo apt -y update

# make sure additional requirments are installed

# Setup Golang 1.12

# mkdir /tmp/dsi309gdkh7 -p
# curl -O  https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz -o /tmp/dsi309gdkh7/golang.tar.gz
# tar -xvf /tmp/dsi309gdkh7/golang.tar.gz
# mv go /usr/local/bin/
# rm /tmp/dsi309gdkh7
# if [[  $PATH != *go* ]]; then
#   export PATH=$PATH:/usr/local/bin/go/bin
# fi


##No bind-utils. It is for host, nslookop,..., no need in ubuntu
sudo apt -y install \
  jq \
  libguestfs-tools \
  nodejs \
  podman \
  qemu-kvm \
  libvirt-bin libvirt-clients libvirt-dev \
  python-ironicclient \
  python-ironic-inspector-client \
  golang-go \
  python-lxml \
  unzip \
  yarn \
  genisoimage

# Install python packages not included as rpms
sudo pip install \
  ansible==2.8.2 \
  lolcat \
  yq \
  virtualbmc \
  python-ironicclient \
  python-ironic-inspector-client \
  lxml \
  netaddr \
  requests \
  setuptools \
  libvirt \

if ! which minikube 2>/dev/null ; then
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
          && chmod +x minikube && sudo mv minikube /usr/local/bin/.
fi

if ! which docker-machine-driver-kvm2 >/dev/null ; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 \
          && sudo install docker-machine-driver-kvm2 /usr/local/bin/
fi

if ! which kubectl 2>/dev/null ; then
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
        && chmod +x kubectl && sudo mv kubectl /usr/local/bin/.
fi

if ! which kustomize 2>/dev/null ; then
    curl -Lo kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/v2.0.3/kustomize_2.0.3_linux_amd64 \
          && chmod +x kustomize && sudo mv kustomize /usr/local/bin/.
fi
