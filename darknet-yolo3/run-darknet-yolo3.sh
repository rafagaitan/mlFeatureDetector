#!/bin/bash

CURRENT_DIR=$(pwd -P)
WEIGHTS='yolov3.weights'
CFG='cfg/yolov3.cfg'
TEST_DATASET='cfg/coco.data'

source build-darknet.sh

function run_yolo {
    if [ ! -e "$CURRENT_DIR/darknet/darknet" ]; then
	echo "Yolo executable not found"
        return
    fi
    mkdir predictions
    ls -1a $1/* > $CURRENT_DIR/validation.txt
    cd $CURRENT_DIR/darknet;
    ./darknet detector test $TEST_DATASET $CFG $WEIGHTS -dont_show -ext_output -out $CURRENT_DIR/result.json -map < $CURRENT_DIR/validation.txt
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

build_yolo
download_validation_images
validation_path="$CURRENT_DIR/validation"
run_yolo "$validation_path"
cd $CURRENT_DIR
