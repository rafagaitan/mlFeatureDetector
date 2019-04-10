#!/bin/bash

CURRENT_DIR=$(pwd -P)
WEIGHTS='yolov3.weights'
CFG='cfg/yolov3.cfg'
GPU=$(command -v nvcc >/dev/null && echo 1 || echo 0)

function build_yolo {
    if [ -e "darknet/darknet" ]; then
        return
    fi
    git clone https://github.com/pjreddie/darknet
    cd $CURRENT_DIR/darknet;
    if [ $GPU -eq 1 ]; then
	echo "Building with GPU"
        sed -i 's/GPU=0/GPU=1/g' Makefile
    fi
    make -j 9
    cd $CURRENT_DIR
}

function prepare_yolo {
    build_yolo
    cd $CURRENT_DIR/darknet;
    wget -nc https://pjreddie.com/media/files/yolov3.weights
    cd $CURRENT_DIR
}

function run_yolo {
    if [ ! -e "darknet/darknet" ]; then
	echo "Yolo executable not found"
        return
    fi
    mkdir predictions
    local images=$(ls $1/*)
    cd $CURRENT_DIR/darknet;
    for image in $images;
    do
        ./darknet detect $CFG $WEIGHTS $image
        name=$(basename $image)
        mv predictions.jpg ../predictions/predictions_$name
    done
    cd $CURRENT_DIR
}

function download_validation_images {
    cd $CURRENT_DIR
    if [ -d "validation" ]; then
        return
    fi
    if [ ! -f "validation.tar.gz" ]; then
        wget https://www.dropbox.com/s/5vyh4kt4jfnixvr/validation.tar.gz?dl=0 -O validation.tar.gz
    fi
    tar xzvf validation.tar.gz
}

prepare_yolo
download_validation_images
validation_path="$CURRENT_DIR/validation"
run_yolo "$validation_path"
cd $CURRENT_DIR
