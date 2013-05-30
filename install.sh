#!/usr/bin/env bash

set -e

if [ -e carp ]; then
  echo "'carp' already exists"
  exit 1
fi

apt-get install --yes git
git clone git://github.com/blom/carp.git

cd carp
exec bash bootstrap.sh
