#!/bin/bash

CURRENT_DIR=$(pwd -P)

source build-darknet.sh
source download-openimages.sh

function prepare_training_files
{
    mkdir -p $CURRENT_DIR/cfg
    mkdir -p $CURRENT_DIR/cfg/backup

    cat > $CURRENT_DIR/cfg/mlFeaturesDetector.names <<EOL
$1
EOL

}

function train_yolo {
    if [ ! -e "$CURRENT_DIR/darknet/darknet" ]; then
	echo "Yolo executable not found"
        return
    fi
    CFG='$CURRENT_DIR/cfg/mlFeaturesDetector.cfg'
    DATA='$CURRENT_DIR/cfg/$1.data'
    cd $CURRENT_DIR/darknet;
    cd $CURRENT_DIR
}

if [[ $# -eq 0 ]] ; then
    echo 'Missing class to train parameter check OpenImagesV4 dataset online for class names'
    exit 1
fi

build_darknet
download_images $1
prepare_training_files $1
cd $CURRENT_DIR
