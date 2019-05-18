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
    cd $CURRENT_DIR
    class_name=$(echo $1 | sed 's/_/ /g')
    echo "Generating train bounding box files..."
    python ./OIDv4_to_yolov3.py $OIDv4_ToolKit_DIR/OID/csv_folder "$class_name" "$CURRENT_DIR/OIDv4_ToolKit/OID/Dataset/train/$class_name"
    echo "Train bounding box files generated."
}

function train_yolo {
    if [ ! -e "$CURRENT_DIR/darknet/darknet" ]; then
	echo "Yolo executable not found"
        return
    fi
    CFG='$CURRENT_DIR/cfg/mlFeaturesDetector.cfg'
    DATA='$CURRENT_DIR/cfg/mlFeaturesDetector.data'

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
