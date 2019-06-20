#!/usr/bin/env bash
set -e
set -x

GYP_ARGS="--runtime=electron --target=${ELECTRON_VERSION} --dist-url=https://atom.io/download/electron"
export PATH="./node_modules/.bin:$PATH"

pushd sqlcipher
./configure --enable-tempstore=yes --enable-load-extension --disable-tcl CFLAGS="-DSQLITE_HAS_CODEC -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_FTS5" CPPFLAGS="-I$(brew --prefix openssl)/include" LDFLAGS="-L$(brew --prefix openssl)/lib"
make
popd

pushd node-sqlite3
npm install --build-from-source --clang=1 --sqlite_libname=sqlcipher --sqlite=../sqlcipher/ ${GYP_ARGS}
node-pre-gyp package ${GYP_ARGS}

sed -e s#.*\"host\":.*#\"host\":\"https://static.freastro.net.s3.amazonaws.com\",# package.json > package.json.new
mv package.json.new package.json
node-pre-gyp publish ${GYP_ARGS}
