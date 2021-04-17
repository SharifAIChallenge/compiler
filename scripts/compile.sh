#! /bin/bash

LANG=$2
CODE_PATH=`realpath $1`
BIN_ZIP_PATH=`realpath $3`
ROOT_DIR=$PWD
LOG_PATH=$ROOT_DIR/compile.log
BIN_PATH=$ROOT_DIR/binary

function clean_up {
  # clean up
  rm -rf $ROOT_DIR/isolated
  rm -rf $CODE_PATH
  rm -rf $BIN_PATH
}

source bin-maker.sh
source logging.sh

# clean up
rm -rf $ROOT_DIR/isolated
rm -rf $BIN_PATH
empty_log

# make an isolated aread
mkdir isolated
cd isolated
info "made an isolated area"

# change directory to codebase
unzip $CODE_PATH
if [ $? -ne 0 ];then
    clean_up
    fatal "fail to unzip"
    exit -1
fi

codebase_dir=`ls -d */ | head -n1`
dir_count=`ls | wc |  awk '{print$1}'`
if [ -z  "$codebase_dir" ] || [ $dir_count -ne 1 ] ;then
    warn "no directory found in given source file"
    codebase_dir="./"
fi
cd $codebase_dir
info "entered the code base"

#compile
case $LANG in
  python|py|py3|python3|PYTHON|PY|PY3|PYTHON3)
    python-bin
    echo "return code:$?"
    [ $? -ne 0 ] && exit -1  
    ;;
  cpp|c|C|CPP)
    cpp-bin
    [ $? -ne 0 ] && exit -1
    ;;
  java|JAVA)
    java-bin
    [ $? -ne 0 ] && exit -1
    ;;
  jar|JAR)
    jar-bin
    [ $? -ne 0 ] && exit -1
    ;;
  bin|BIN)
    bin-bin
    [ $? -ne 0 ] && exit -1
    ;;
  *)
    fatal "type unknown!"
    exit -1
    ;;
esac


# make a tar.gz file
( cd `dirname $BIN_PATH` && tar -cvzf $BIN_ZIP_PATH `basename $BIN_PATH`)

if [ $? -eq 0 ];then
    info "bin.zip file is ready to use"
    clean_up
    exit 0
else
    fatal "couldn't make the zip file"
    exit -1
fi
