#!/usr/bin/env bash

set -e

. /etc/lsb-release

wget http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb
dpkg --install puppetlabs-release-precise.deb

cat > /etc/apt/sources.list <<__EOF__
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME} main
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME}-updates main
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME}-security main
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME} universe
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME}-updates universe
__EOF__

rm -f /boot/grub/menu.lst
update-grub -y

apt-get update
apt-get --yes dist-upgrade

packages=(
  git
  puppet
  rake
  ruby1.9.3
  rubygems
)
apt-get --yes install ${packages[*]}

update-alternatives --set ruby /usr/bin/ruby1.9.1
update-alternatives --set gem /usr/bin/gem1.9.1

cat > /etc/gemrc <<__EOF__
gem: --no-rdoc --no-ri
:sources:
  - https://rubygems.org/
__EOF__

if ! gem list | grep -q librarian-puppet; then
  gem install librarian-puppet
fi

librarian-puppet install --path=/etc/puppet/modules

exec puppet apply bootstrap.pp
