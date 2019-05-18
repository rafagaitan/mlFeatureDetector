#!/bin/bash

#DARKNET_REPO=https://github.com/pjreddie/darknet
DARKNET_REPO=https://github.com/AlexeyAB/darknet.git
CURRENT_DIR=$(pwd -P)
GPU=$(command -v nvcc >/dev/null && echo 1 || echo 0)

function build_darknet {
    if [ -e "$CURRENT_DIR/darknet/darknet" ]; then
        return
    fi
    git clone $DARKNET_REPO
    cd $CURRENT_DIR/darknet;
    export CC=clang
    export CXX=clang++
    mkdir build-release
    cd build-release
    cmake .. -DCMAKE_DISABLE_FIND_PACKAGE_OpenMP=TRUE -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$CURRENT_DIR/darknet-sdk
    make -j 9 install

    #if [ $GPU -eq 1 ]; then
    #  echo "Building with GPU"
    #  sed -i 's/GPU=0/GPU=1/g' Makefile
    #  sed -i 's/CUDNN=0/CUDNN=1/g' Makefile
    #fi
    #make -j 9
    cd $CURRENT_DIR
}


