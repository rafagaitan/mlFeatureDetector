#!/bin/bash

CURRENT_DIR=$(pwd -P)
WEIGHTS='yolov3.weights'
CFG='cfg/yolov3.cfg'

function prepare_yolo {
    if [ -e "darknet/darknet" ]; then
        return
    fi
    git clone https://github.com/pjreddie/darknet
    cd darknet;
    make
    wget https://pjreddie.com/media/files/yolov3.weights
    cd ..;
}

function run_yolo {
    mkdir predictions
    local images=$(ls $1/*)
    cd darknet;
    for image in $images;
    do
        ./darknet detect $CFG $WEIGHTS $image
        name=$(basename $image)
        mv predictions.jpg ../predictions/predictions_$name
    done
    cd -;
}

function download_validation_images {
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

