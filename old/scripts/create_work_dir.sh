#!/usr/bin/env bash
#
# Copyright (C) 2023 BlackMesa123
#

set -eu

KITCHEN_HOME=$(pwd)
KITCHEN_SCRIPTS=$KITCHEN_HOME/scripts
LOG_DIR="$KITCHEN_HOME/logs"
BINN="$KITCHEN_HOME/ext/bin"
declare -r ODIN_DIR="$KITCHEN_HOME/projects/$prj"
declare -r WORK_DIR="$ODIN_DIR/work_dir"

# Create work directory
mkdir -p "$WORK_DIR"
mkdir -p "$WORK_DIR/configs"

COPY_SOURCE_FIRMWARE() {
    local MODEL
    local REGION
    MODEL=$(echo -n "$SOURCE_FIRMWARE" | cut -d "/" -f 1)
    REGION=$(echo -n "$SOURCE_FIRMWARE" | cut -d "/" -f 2)

    local COMMON_FOLDERS="odm product system"
    for folder in $COMMON_FOLDERS; do
        if [ ! -d "$WORK_DIR/$folder" ]; then
            mkdir -p "$WORK_DIR/$folder"
            cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/$folder" "$WORK_DIR"
            cp --preserve=all "$FW_DIR/${MODEL}_${REGION}/file_context-$folder" "$WORK_DIR/configs"
            cp --preserve=all "$FW_DIR/${MODEL}_${REGION}/fs_config-$folder" "$WORK_DIR/configs"
        fi
    done
}

COPY_TARGET_FIRMWARE() {
    local MODEL
    local REGION
    MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)
    REGION=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 2)

    local COMMON_FOLDERS="system_dlkm vendor vendor_dlkm"
    for folder in $COMMON_FOLDERS; do
        [[ ! -d "$FW_DIR/${MODEL}_${REGION}/$folder" ]] && continue
        if [ ! -d "$WORK_DIR/$folder" ]; then
            mkdir -p "$WORK_DIR/$folder"
            cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/$folder" "$WORK_DIR"
            cp --preserve=all "$FW_DIR/${MODEL}_${REGION}/file_context-$folder" "$WORK_DIR/configs"
            cp --preserve=all "$FW_DIR/${MODEL}_${REGION}/fs_config-$folder" "$WORK_DIR/configs"
        fi
    done
}

COPY_TARGET_KERNEL() {
    local MODEL
    local REGION
    MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)
    REGION=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 2)

    mkdir -p "$WORK_DIR/kernel"

    local COMMON_KERNEL_BINS="boot.img dtbo.img init_boot.img vendor_boot.img"
    for i in $COMMON_KERNEL_BINS; do
        [ ! -f "$FW_DIR/${MODEL}_${REGION}/$i" ] && continue
        cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/$i" "$WORK_DIR/kernel/$i"
        $TARGET_KEEP_ORIGINAL_SIGN || bash "$SRC_DIR/scripts/unsign_bin.sh" "$WORK_DIR/kernel/$i" &> /dev/null
    done
    if $TARGET_INCLUDE_PATCHED_VBMETA; then
        cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/vbmeta_patched.img" "$WORK_DIR/kernel/vbmeta.img"
    fi
}

COPY_SOURCE_FIRMWARE 
COPY_TARGET_FIRMWARE
COPY_TARGET_KERNEL

exit 0
