#!/usr/bin/env bash
#
# Copyright (C) 2023 BlackMesa123, JeyKul, AnanJaser1211

set -euo pipefail

#echo hello world

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    if [[ ! -f "venv/bin/activate" ]]; then
        python3 -m venv venv >/dev/null 2>&1 || {
            echo "Error: Python venv module is not installed." >&2
            exit 1
        }
    fi

    source venv/bin/activate >/dev/null 2>&1
    echo "hello venv"
fi

get_latest_firmware() {
    local region=$1
    local model=$2
    curl -s --retry 5 --retry-delay 5 "https://fota-cloud-dn.ospserver.net/firmware/$region/$model/version.xml" \
        | grep latest | sed 's/^[^>]*>//' | sed 's/<.*//'
        echo what
}

download_firmware() {

    echo "Downloading firmware for $model ($region)..." | tee -a "$LOG_FILE"

    mkdir -p "$target_dir" || { echo "Failed to create directory: $target_dir" | tee -a "$LOG_FILE"; exit 1; }


imei="${imei//[[:space:]]/}"

local samloader_flags
if [[ "${#imei}" -eq 15 || "${#imei}" -eq 8 ]]; then
    samloader_flags=("-i" "$imei")
elif [[ "${#imei}" -eq 11 ]]; then
    samloader_flags=("-s" "$imei") 
else
    echo "Error: IMEI must be 8 or 15 digits, or Serial Number must be 11 digits." >&2
    exit 1
fi

echo "samloader -m \"$model\" -r \"$region\" ${samloader_flags[*]} download -O \"$target_dir\""
if ! samloader -m "$model" -r "$region" "${samloader_flags[@]}" download -O "$target_dir"; then
    echo "FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUCK"
    exit 1
fi

    touch "$target_dir/.downloaded"

    local zip_file
    zip_file=$(find "$target_dir" -name "*.zip" | head -n 1)
    if [[ -f "$zip_file" ]]; then
        echo "Unzipping $zip_file..." | tee -a "$LOG_FILE"
        if ! unzip -q "$zip_file" -d "$target_dir" >> "$LOG_FILE" 2>&1; then
            echo "Failed to unzip $zip_file. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
            exit 1
        fi
        rm "$zip_file"
    else
        echo "No ZIP file found in $target_dir." | tee -a "$LOG_FILE"
        exit 1
    fi

    {
        echo -n "$(find "$target_dir" -name "AP*" -exec basename {} \; | cut -d "_" -f 2)/"
        echo -n "$(find "$target_dir" -name "CSC*" -exec basename {} \; | cut -d "_" -f 3)/"
        echo -n "$(find "$target_dir" -name "CP*" -exec basename {} \; | cut -d "_" -f 2)"
    } >> "$target_dir/.downloaded"

    echo "Firmware download and extraction completed successfully!" | tee -a "$LOG_FILE"
}

handle_firmware_update() {
    local model=$1
    local region=$2
    local imei=$3
    local force=$4

    local target_dir="$ODIN_DIR/${model}_${region}"
    local latest_firmware
    latest_firmware=$(get_latest_firmware "$region" "$model")

    if [[ -f "$target_dir/.downloaded" ]]; then
        if [[ -z "$latest_firmware" ]]; then
            echo "No new firmware available for $model ($region). Skipping..." | tee -a "$LOG_FILE"
            return
        fi

        local downloaded_firmware
        downloaded_firmware=$(cat "$target_dir/.downloaded")

        if [[ "$latest_firmware" != "$downloaded_firmware" ]]; then
            if $force; then
                echo "A newer firmware version is available. Updating..." | tee -a "$LOG_FILE"
                rm -rf "$target_dir"
                download_firmware "$model" "$region" "$imei"
            else
                echo "A newer firmware version is available. Use --force to update." | tee -a "$LOG_FILE"
            fi
        else
            echo "Firmware for $model ($region) is already up to date." | tee -a "$LOG_FILE"
        fi
    else
        echo "Downloading firmware for $model ($region)..." | tee -a "$LOG_FILE"
        download_firmware "$model" "$region" "$imei"
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
    local imei=$3

    mkdir -p "$ODIN_DIR"

    handle_firmware_update "$model" "$region" "$imei" "$force"
}

main "$@"
