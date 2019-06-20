#!/usr/bin/env bash
set -e
set -x

# Install required node version
rm -rf nvm && git clone --depth 1 https://github.com/creationix/nvm.git
source nvm/nvm.sh
nvm install $NODE_VERSION
nvm use $NODE_VERSION

# Debugging output
echo "Using node $(node --version) at $(which node)"
echo "Using npm $(npm --version) at $(which npm)"
