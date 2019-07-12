#!/usr/bin/env bash
set -e
set -x

unset CC
GYP_ARGS="--runtime=electron --target=${ELECTRON_VERSION} --dist-url=https://atom.io/download/electron"
export NVM_HOME="C:\\ProgramData\\nvm"
export NVM_SYMLINK="C:\\Program Files\\nodejs"
export PATH="./node_modules/.bin:/c/Tcl/bin:/c/Program Files/Amazon/cfn-bootstrap:/c/Program Files/Amazon/AWSCLI/bin:/c/ProgramData/nvm:/c/Program Files/nodejs:$PATH"
PREFIX="$(pwd)/sqlcipher"

pushd sqlcipher
sed -e 's/^SQLITE3DLL = .*/SQLITE3DLL = sqlcipher.dll/' \
    -e 's/^SQLITE3LIB = .*/SQLITE3LIB = sqlcipher.lib/' \
    -e 's/^SQLITE3EXE = .*/SQLITE3EXE = sqlcipher.exe/' \
    -e 's#^SQLITE3EXEPDB = .*#SQLITE3EXEPDB = /pdb:sqlciphersh.pdb#' \
    -e 's/-DSQLITE_TEMP_STORE=1/-DSQLITE_TEMP_STORE=2 -DSQLITE_HAS_CODEC -IC:\\dev\\OpenSSL-Win64\\include/' \
    Makefile.msc > Makefile.msc.new
mv Makefile.msc.new Makefile.msc
MSYS2_ARG_CONV_EXCL="*" cmd /c call 'C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\VC\\Auxiliary\\Build\\vcvars64.bat' \&\& nmake /f Makefile.msc "LTLIBPATHS=/LIBPATH:C:\\dev\\OpenSSL-Win64\\lib /LIBPATH:C:\\dev\\OpenSSL-Win64\\lib\\VC" "LTLIBS=libcrypto.lib"
mkdir -p build/include
cp sqlite3.h build/include/
popd

pushd node-sqlite3
npm install --build-from-source --clang=1 --sqlite_libname=$(pwd)/../sqlcipher/sqlcipher --sqlite="${PREFIX}/build" --msvs_version=2017 ${GYP_ARGS}
node-pre-gyp package ${GYP_ARGS}

if [[ ! -z "${AWS_ACCESS_KEY_ID}" && ! -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  pushd build/stage
  find sqlite3 -type f -exec aws s3 cp {} s3://static.freastro.net/{} \;
  aws s3 cp "$(pwd)/../sqlcipher/sqlcipher.dll" s3://static.freastro.net/sqlite3/sqlcipher.dll
  popd
fi
