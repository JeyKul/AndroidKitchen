#!/bin/bash
export PROJECTS_DIR="projects"
export DOWNLOADS_DIR="downloads"
export INPUT_DIR="input"
export WORKDIR_DIR="workdir"
export LOG_DIR="logs"
export KHOME=$(pwd)
export KSCRIPTS=$KHOME/scripts
export LOG_FILE="$LOG_DIR/download_fw.log"
export BINN="$KITCHEN_HOME/ext/bin"

$KSCRIPTS/check_dependencies.sh
export PATH=$PATH:$BINARYPATH
echo "Creating required directories..."
mkdir -p "$PROJECTS_DIR" "$DOWNLOADS_DIR" "$INPUT_DIR" "$WORKDIR_DIR" "$LOG_DIR"
echo "Directories created successfully!"
source $KHOME/venv/bin/activate > /dev/null