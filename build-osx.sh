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

if [[ ! -z "${node_pre_gyp_accessKeyId}" && ! -z "${node_pre_gyp_secretAccessKey}" ]]; then
  sed -e s#.*\"host\":.*#\"host\":\"https://static.freastro.net.s3.amazonaws.com\",# package.json > package.json.new
  mv package.json.new package.json
  node-pre-gyp publish ${GYP_ARGS}
fi
