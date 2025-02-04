#!/bin/bash
export PROJECTS_DIR="projects"
export DOWNLOADS_DIR="downloads"
export INPUT_DIR="input"
export WORKDIR_DIR="workdir"
export LOG_DIR="logs"
export KHOME=$(pwd)
export KSCRIPTS=$KHOME/scripts
export LOG_FILE="$LOG_DIR/download_fw.log"
export BINN="$KHOME/ext/bin"

$KSCRIPTS/check_dependencies.sh
export PATH=$PATH:$BINARYPATH
echo "Creating required directories..."
mkdir -p "$PROJECTS_DIR" "$DOWNLOADS_DIR" "$INPUT_DIR" "$WORKDIR_DIR" "$LOG_DIR"
echo "Directories created successfully!"

if [ ! -f "$KHOME/venv/bin/activate" ]; then
  echo "Virtual environment not found, creating it..."
  python3 -m venv "$KHOME/venv"
else
  echo "Virtual environment already exists, continuing..."
fi
source $KHOME/venv/bin/activate > /dev/null

if [ -z "$debug" ]; then
  export debug=0
fi

if [ "$debug" -eq 0 ]; then
        pip3 install git+https://github.com/ananjaser1211/samloader.git > /dev/null 2>&1
else
        echo "$PROJECTS_DIR" 
        echo "$DOWNLOADS_DIR" 
        echo "$INPUT_DIR" 
        echo "$WORKDIR_DIR" 
        echo "$LOG_DIR"  
        echo "$KHOME" 
        echo "$KSCRIPTS" 
        echo "$LOG_FILE"
        pip3 install git+https://github.com/ananjaser1211/samloader.git
fi

echo "$debug_output"
