#!/usr/bin/env bash
set -e
set -x

choco install -y awscli nvm
export NVM_HOME="C:\\ProgramData\\nvm"
export NVM_SYMLINK="C:\\Program Files\\nodejs"
export PATH="/c/Program Files/Amazon/cfn-bootstrap:/c/Program Files/Amazon/AWSCLI/bin:/c/ProgramData/nvm:/c/Program Files/nodejs:$PATH"

aws s3 cp s3://static.freastro.net/sqlite3/ActiveTcl-8.5.18.0.298892-win32-x86_64-threaded.zip ActiveTcl.zip
unzip ActiveTcl.zip -d /c/

aws s3 cp s3://static.freastro.net/sqlite3/Win64OpenSSL-1_1_1c.zip Win64OpenSSL.zip
mkdir /c/dev
unzip Win64OpenSSL.zip -d /c/dev/

# Install required node version
nvm install $NODE_VERSION
nvm use $NODE_VERSION

# Debugging output
echo "Using node $(node --version) at $(which node)"
echo "Using npm $(npm --version) at $(which npm)"
