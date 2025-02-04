#!/usr/bin/env bash
#
# Copyright (C) 2023 BlackMesa123

set -e

# Ensure fakeroot is installed
if ! command -v fakeroot &>/dev/null; then
    echo "Error: fakeroot is not installed. Please install it first."
    exit 1
fi


KITCHEN_HOME=$(pwd)
config_file=$KITCHEN_HOME/config.json
prj=$(jq -r '.project_name' "$config_file")
KITCHEN_SCRIPTS=$KITCHEN_HOME/scripts
LOG_DIR="$KITCHEN_HOME/logs"
BINN="$KITCHEN_HOME/ext/bin"
declare -r ODIN_DIR="$KITCHEN_HOME/projects/$prj/downloads"
declare -r LOG_FILE="$LOG_DIR/download_fw.log"

# Default paths (to be overridden by arguments)
#SOURCE_FOLDER=""
#DEST_FOLDER=""
AP_ARCHIVE=$(ls "$SOURCE_FOLDER" | grep -i "AP")
BL_ARCHIVE=$(ls "$SOURCE_FOLDER" | grep -i "BL")
CP_ARCHIVE=$(ls "$SOURCE_FOLDER" | grep -i "CP")
CSC_ARCHIVE=$(ls "$SOURCE_FOLDER" | grep -i "CSC")
s2i=$BINN/simg2img
lpup=$BINN/lpunpack
# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--source)
            SOURCE_FOLDER="$2"
            shift 2
            ;;
        -d|--dest)
            DEST_FOLDER="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: extract_fw.sh --source <source_folder> --dest <destination_folder>"
            exit 1
            ;;
    esac
done

# Ensure both source and destination are set
if [[ -z "$SOURCE_FOLDER" ]] || [[ -z "$DEST_FOLDER" ]]; then
    echo "Error: Both source and destination folders must be provided."
    echo "Usage: extract_fw.sh --source <source_folder> --dest <destination_folder>"
    exit 1
fi

# Verify that the source folder exists
if [[ ! -d "$SOURCE_FOLDER" ]]; then
    echo "Error: Source folder '$SOURCE_FOLDER' does not exist."
    exit 1
fi

# Create destination folder if it doesn't exist
mkdir -p "$DEST_FOLDER"

EXTRACT_KERNEL_BINARIES() {
    echo "- Extracting kernel binaries..."
    cd "$DEST_FOLDER"
    local FILES=(boot.img.lz4 dtbo.img.lz4 init_boot.img.lz4 vendor_boot.img.lz4)
    for file in "${FILES[@]}"; do
        tar tf "$SOURCE_FOLDER/$AP_ARCHIVE" "$file" || continue
        echo "Extracting $file"
        tar xf "$SOURCE_FOLDER/$AP_ARCHIVE" "$file" && lz4 -d -q --rm "$file" "${file%.lz4}"
    done
    cd - &>/dev/null
}

EXTRACT_OS_PARTITIONS() {
    echo "- Extracting OS partitions using fakeroot..."
    cd "$DEST_FOLDER"
    tar xf "$SOURCE_FOLDER/$AP_ARCHIVE" "super.img.lz4"
    lz4 -d -q --rm "super.img.lz4" "super.img.sparse"
    $s2i "super.img.sparse" "super.img" && rm "super.img.sparse"
    $lpup "super.img"
    rm "super.img"
    cd - &>/dev/null
}

EXTRACT_AVB_BINARIES() {
    echo "- Extracting AVB binaries..."
    cd "$DEST_FOLDER"
    tar xf "$SOURCE_FOLDER/$BL_ARCHIVE" "vbmeta.img.lz4" && lz4 -d -q --rm "vbmeta.img.lz4" "vbmeta.img"
    cp "vbmeta.img" "vbmeta_patched.img"
    printf "\x03" | dd of="vbmeta_patched.img" bs=1 seek=123 count=1 conv=notrunc &> /dev/null
    cd - &>/dev/null
}

EXTRACT_ALL() {
    mkdir -p "$DEST_FOLDER"
    EXTRACT_KERNEL_BINARIES
    EXTRACT_OS_PARTITIONS
    EXTRACT_AVB_BINARIES
    echo "Extraction completed successfully."
}

EXTRACT_ALL
exit 0
