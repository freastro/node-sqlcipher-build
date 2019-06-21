#!/usr/bin/env bash
set -e
set -x

GYP_ARGS="--runtime=electron --target=${ELECTRON_VERSION} --dist-url=https://atom.io/download/electron"
export PATH="./node_modules/.bin:$PATH"

mkdir build
PREFIX="$(pwd)/build"

pushd sqlcipher
./configure --prefix="${PREFIX}" --enable-tempstore=yes --enable-load-extension --disable-tcl CFLAGS="-DSQLITE_HAS_CODEC -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_FTS5" CPPFLAGS="-I$(brew --prefix openssl)/include" LDFLAGS="-L$(brew --prefix openssl)/lib"
make
make install
popd

pushd node-sqlite3
npm install --build-from-source --clang=1 --sqlite_libname=sqlcipher --sqlite="${PREFIX}" ${GYP_ARGS}
node-pre-gyp package ${GYP_ARGS}

if [[ ! -z "${AWS_ACCESS_KEY_ID}" && ! -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  pushd build/stage
  find sqlite3 -type f -exec aws s3 cp {} s3://static.freastro.net/{} \;
  popd
fi
