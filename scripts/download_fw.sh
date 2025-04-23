#!/usr/bin/env bash
#
# Copyright (C) 2023 BlackMesa123, JeyKul, AnanJaser1211

set -euo pipefail
SCRIPT="download_fw-"`date +"%H-%M-%S"`".txt"
source $CONFIG
echo $SCRIPT
echo $LOG_FILE
echo $IMEI

#echo hello world

get_latest_firmware() {
    local region=$1
    local model=$2
    curl -s --retry 5 --retry-delay 5 "https://fota-cloud-dn.ospserver.net/firmware/$region/$model/version.xml" \
        | grep latest | sed 's/^[^>]*>//' | sed 's/<.*//'
        echo what
}

download_firmware() {
    source $CONFIG

    echo "Downloading firmware for $MDLNR ($CSC) with $IMEI " | tee -a "$LOG_FILE"

    mkdir -p "$TARGETDL" || { echo "Failed to create directory: $TARGETDL" | tee -a "$LOG_FILE"; exit 1; }

    echo $IMEI

    imei="${IMEI//[[:space:]]/}"

    echo $imei

    if [[ $imei =~ ^[0-9]{15}$ || $imei =~ ^[0-9]{8}$ ]]; then
        samloader_flags=("-i" "$imei")
    elif [[ $imei =~ ^[0-9]{11}$ ]]; then
        samloader_flags=("-s" "$imei")
    else
        echo "Error: IMEI must be 8 or 15 digits, or Serial Number must be 11 digits." >&2
        exit 1
    fi



    echo "samloader -m \"$MDLNR\" -r \"$CSC\" ${samloader_flags[*]} download -O \"$TARGETDL\""
    if ! samloader -m "$MDLNR" -r "$CSC" "${samloader_flags[@]}" download -O "$TARGETDL"; then
        echo "FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUCK"
        exit 1
    fi

    touch "$TARGETDL/.downloaded"

    local zip_file
    zip_file=$(find "$TARGETDL" -name "*.zip" | head -n 1)
    if [[ -f "$zip_file" ]]; then
        echo "Unzipping $zip_file..." | tee -a "$LOG_FILE"
        if ! unzip -q "$zip_file" -d "$TARGETDL" >> "$LOG_FILE" 2>&1; then
            echo "Failed to unzip $zip_file. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
            exit 1
        fi
        rm "$zip_file"
    else
        echo "No ZIP file found in $TARGETDL." | tee -a "$LOG_FILE"
        exit 1
    fi

    {
        echo -n "$(find "$TARGETDL" -name "AP*" -exec basename {} \; | cut -d "_" -f 2)/"
        echo -n "$(find "$TARGETDL" -name "CSC*" -exec basename {} \; | cut -d "_" -f 3)/"
        echo -n "$(find "$TARGETDL" -name "CP*" -exec basename {} \; | cut -d "_" -f 2)"
    } >> "$TARGETDL/.downloaded"

    echo "Firmware download and extraction completed successfully!" | tee -a "$LOG_FILE"
}

handle_firmware_update() {
    local model=$1
    local region=$2
    local imei=$3
    local force=$4

    local latest_firmware
    latest_firmware=$(get_latest_firmware "$region" "$model")

    if [[ -f "$TARGETDL/.downloaded" ]]; then
        if [[ -z "$latest_firmware" ]]; then
            echo "No new firmware available for $model ($region). Skipping..." | tee -a "$LOG_FILE"
            return
        fi

        local downloaded_firmware
        downloaded_firmware=$(cat "$TARGETDL/.downloaded")

        if [[ "$latest_firmware" != "$downloaded_firmware" ]]; then
            if $force; then
                echo "A newer firmware version is available. Updating..." | tee -a "$LOG_FILE"
                rm -rf "$TARGETDL"
                download_firmware "$model" "$region" "$IMEI"
            else
                echo "A newer firmware version is available. Use --force to update." | tee -a "$LOG_FILE"
            fi
        else
            echo "Firmware for $model ($region) is already up to date." | tee -a "$LOG_FILE"
        fi
    else
        echo "Downloading firmware for $model ($region)..." | tee -a "$LOG_FILE"
        download_firmware "$model" "$region" "$IMEI"
    fi
}

main() {
    local force=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            "-f" | "--force")
                force=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    if [[ $# -ne 3 ]]; then
        echo "Usage: $0 [-f|--force] <model> <region> <imei>"
        exit 1
    fi

    local model=$1
    local region=$2
    local IMEI=$3

    mkdir -p "$TARGETDL"

    handle_firmware_update "$model" "$region" "$IMEI" "$force"
}

main "$@"
