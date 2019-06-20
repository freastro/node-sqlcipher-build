#!/usr/bin/env bash
set -e
set -x

cd node-sqlite3
GYP_ARGS="--runtime=electron --target=${ELECTRON_VERSION} --dist-url=https://atom.io/download/electron"
export PATH="./node_modules/.bin:$PATH"

npm install --build-from-source --clang=1 ${GYP_ARGS}
npm install -g electron@${ELECTRON_VERSION}
node-pre-gyp package ${GYP_ARGS}
node-pre-gpy publish ${GYP_ARGS}
