#!/usr/bin/env bash

set -e
cd $(dirname ${0})

. /etc/lsb-release

cat > /etc/apt/sources.list <<__EOF__
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME} main
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME}-updates main
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME}-security main
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME} universe
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME}-updates universe
__EOF__

rm -f /boot/grub/menu.lst
update-grub

apt-get update
apt-get --yes dist-upgrade

packages=(
  git
  ruby1.9.3
)
apt-get --yes install ${packages[*]}

update-alternatives --set ruby /usr/bin/ruby1.9.1
update-alternatives --set gem /usr/bin/gem1.9.1

cat > /etc/gemrc <<__EOF__
gem: --no-rdoc --no-ri
:sources:
  - https://rubygems.org/
__EOF__

geminst() {
  if ! gem list | egrep -q "^$1\s"; then
    gem install $1
  fi
}

geminst puppet
geminst r10k

r10k puppetfile install

exec puppet apply --modulepath=./modules bootstrap.pp
