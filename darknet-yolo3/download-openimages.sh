
CURRENT_DIR=$(pwd -P)
OIDv4_ToolKit_DIR=$CURRENT_DIR/OIDv4_ToolKit

function download_oidv4_toolkit
{    
    if [ -e "$OIDv4_ToolKit_DIR" ]; then
        return
    fi
    git clone https://github.com/EscVM/OIDv4_ToolKit.git $OIDv4_ToolKit_DIR
    cd $OIDv4_ToolKit_DIR
    pipenv install -r requirements.txt
}

function download_images
{
    cd $CURRENT_DIR
    download_oidv4_toolkit $1
    cd $OIDv4_ToolKit_DIR
    python3 main.py downloader --classes $1 --type_csv all 
    cd $CURRENT_DIR
}

download_images $1
